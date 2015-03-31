#!/usr/bin/env ruby
require 'core'
include Core::Commands
module Ducky
  class Writer
    def menu
      _options.each do |key, ops|
        puts "#{key}) #{ops}"
      end
      rgets('Choice: ', '3')
    end

    def write(choice)
      _options_lambda[choice.to_sym].call
    rescue => e
      puts print_error(e)
    end

    private

    def _options_lambda
      { :'1' => -> () { _admin_with_uac },
        :'2' => -> () { _admin_with_out_uac },
        :'3' => -> () { _low_priv } }
    end

    def _options
      { :'1' => 'admin_with_uac',
        :'2' => 'admin_with_out_uac',
        :'3' => 'low_priv' }
    end

    def _admin_with_uac
      cmd = "DELAY 3000\n"
      cmd << "CTRL ESC\n"
      cmd << "DELAY 200\n"
      cmd << "STRING cmd\n"
      cmd << "CTRL-SHIFT ENTER\n"
      cmd << "DELAY 2000\n"
      cmd << "ALT y\n"
      cmd << "DELAY 2000\n"
      cmd << 'STRING '
    end

    def _admin_with_out_uac
      cmd = "DELAY 2000\n"
      cmd << "CTRL ESC\n"
      cmd << "DELAY 200\n"
      cmd << "STRING cmd\n"
      cmd << "CTRL-SHIFT ENTER\n"
      cmd << "DELAY 2000\n"
      cmd << 'STRING '
    end

    def _low_priv
      cmd = "DELAY 2000\n"
      cmd << "GUI r\n"
      cmd << "DELAY 500\n"
      cmd << "STRING cmd\n"
      cmd << "ENTER\n"
      cmd << "DELAY 500\n"
      cmd << 'STRING '
    end
  end

  class Compile
    include Core::Files
    def initialize(file_name)
      File.open("#{text_path}#{file_name}", 'a') { |f| f.write("\nENTER") }
      choice = _pick_language
      language = _language_options[choice.to_sym]
      print_info('Creating Bin File!')
      cmd = _compile_cmd(file_name, language)
      output = `#{cmd}`
      if output =~ /Exception/
        print_error('Wrong Version of Java')
        print_info('Run update-alternatives --config java and select Java 7')
        exit
      else
        print_info(output)
        print_success('Bin File Created!')
      end
    end

    private

    def _pick_language
      _language_options.each do |key, lang|
        puts "#{key}) #{lang}"
      end
      rgets('Choice: ', '1')
    end

    def _language_options
      { :'1' => 'us.properties', :'2' => 'be.properties',
        :'3' => 'it.properties', :'4' => 'dk.properties',
        :'5' => 'es.properties', :'6' => 'uk.properties',
        :'7' => 'sv.properties', :'8' => 'ru.properties',
        :'9' => 'pt.properties', :'10' => 'de.properties',
        :'11' => 'no.properties', :'12' => 'fr.properties' }
    end

    def _compile_cmd(file_name, language)
      cmd = "java -jar #{duck_encode_file}encoder.jar -i "
      cmd << "#{text_path}#{file_name} -o #{file_root}/inject.bin -l "
      cmd << "#{language_dir}#{language} 2>&1"
    end
  end
end
