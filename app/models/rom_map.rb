class ROMMap < ApplicationModel
  self.datastore = EBYAML.map

  attr_reader :entries

  def initialize(**attributes)
    super
    @entries = []
    rom_file = ROMFile.new
    EBYAML.map.each do |address, entry|
      next unless address.is_a?(Fixnum)
      bank = address >> 16
      offset = address & 0x00ffff
      # ignore addresses outside ROM banks
      next unless bank.between?(0xc0, 0xff) || bank.between?(0x40, 0x7d) ||
        ((bank.between?(0x00, 0x3f) || bank.between?(0x80, 0xbf)) &&
         address.between?(0x8000, 0xffff))
      @entries << ROMEntry.new(offset: entry['offset'],
                               size: entry['size'] || 1,
                               name: entry['name'],
                               description: entry['description'])
    end
  end
end
