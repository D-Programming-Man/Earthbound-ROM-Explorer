require 'yaml'

class ROMMap
  attr_reader :entries

  def initialize
    @entries = []
    # TODO: read rom filename from config file
    rom_filename = Rails.root.join('data', 'Earthbound (U) [!].smc')
    rom_file = File.open(rom_filename, 'rb') do |file|
      ROMFile.new(file)
    end
    # TODO: read yaml filename from config file
    ebyaml_filename = Rails.root.join('data', 'eb.yml')
    ebyaml = File.open(ebyaml_filename, 'r') do |file|
      YAML.load_stream(file.read, ebyaml_filename)[1]
    end
    ebyaml.each do |address, entry|
      next unless address.instance_of?(Fixnum)
      bank = address >> 16
      offset = address & 0x00ffff
      next unless bank.between?(0xc0, 0xff) || bank.between?(0x40, 0x7d) ||
        ((bank.between?(0x00, 0x3f) || bank.between?(0x80, 0xbf)) &&
         address.between?(0x8000, 0xffff))
      @entries << ROMEntry.new(entry['offset'],
                               entry['name'],
                               entry['description'])
    end
  end
end