require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/kusto'
require 'logstash/codecs/plain'
require 'logstash/event'

describe LogStash::Outputs::Kusto do

  let(:options) { { "path" => "./kusto_tst/%{+YYYY-MM-dd-HH-mm}",
    "ingest_url" => "mycluster",
    "app_id" => "myid",
    "app_key" => "mykey",
    "app_tenant" => "mytenant", 
    "database" => "mydatabase",
    "table" => "mytable",
    "mapping" => "mymapping"
  } }

  describe '#register' do
    # this actually tests some the of ingestor class init procedure

    it 'doesnt allow the path to start with a dynamic string' do
      kusto = described_class.new(options.merge( {'path' => '/%{name}'} ))
      expect { kusto.register }.to raise_error(LogStash::ConfigurationError)
      kusto.close
    end

    dynamic_name_array = ['/a%{name}/', '/a %{name}/', '/a- %{name}/', '/a- %{name}']

    context 'doesnt allow the root directory to have some dynamic part' do
      dynamic_name_array.each do |test_path|
         it "with path: #{test_path}" do
           kusto = described_class.new(options.merge( {'path' => test_path} ))
           expect { kusto.register }.to raise_error(LogStash::ConfigurationError)
           kusto.close
         end
       end
    end

    it 'allow to have dynamic part after the file root' do
      kusto = described_class.new(options.merge({'path' => '/tmp/%{name}'}))
      expect { kusto.register }.not_to raise_error
      kusto.close
    end

    context 'doesnt allow database to have some dynamic part' do
      dynamic_name_array.each do |test_database|
        it "with path: #{test_database}" do
          kusto = described_class.new(options.merge( {'database' => test_database} ))
          expect { kusto.register }.to raise_error(LogStash::ConfigurationError)
          kusto.close
        end
      end
    end

    context 'doesnt allow table to have some dynamic part' do
      dynamic_name_array.each do |test_table|
        it "with path: #{test_table}" do
          kusto = described_class.new(options.merge( {'table' => test_table} ))
          expect { kusto.register }.to raise_error(LogStash::ConfigurationError)
          kusto.close
        end
      end
    end

    context 'doesnt allow mapping to have some dynamic part' do
      dynamic_name_array.each do |test_mapping|
        it "with path: #{test_mapping}" do
          kusto = described_class.new(options.merge( {'mapping' => test_mapping} ))
          expect { kusto.register }.to raise_error(LogStash::ConfigurationError)
          kusto.close
        end
      end
    end

  end
  
end