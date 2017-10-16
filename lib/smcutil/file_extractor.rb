class SmcUtil::FileExtractor
  OUTPUT_FILE_FLAGS = File::CREAT | File::TRUNC | File::WRONLY

  def initialize(file_reader)
    @file_reader = file_reader
  end


  def extract_to(path)
    File.open(path, OUTPUT_FILE_FLAGS) do |file|
      @file_reader.regions.each do |region|
        range_bytes = region.offset - file.pos
        file.write "\0" * range_bytes if range_bytes > 0
        file.seek region.offset
        file.write region.data
      end
    end
  end

  def shred_to(path)
    Dir.mkdir(path) unless Dir.exists? path

    pass = position = 0

    @file_reader.regions.each do |region|
      pass += 1 if region.offset < position
      position = region.offset

      filename = File.join(path, "#{region.offset.to_s(16)}_pass#{pass}.bin")

      File.open(filename, OUTPUT_FILE_FLAGS) do |file|
        file.write region.data
      end
    end
  end
end