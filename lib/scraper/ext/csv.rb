require "csv"

class CSV
  class << self
    def append_rows_from_hash(file_path, hash, headers: true, col_sep: ";", **args)
      self.open(file_path, "a+", col_sep: col_sep, **args) do |csv|
        write_hash_in_csv(csv, hash, headers)
      end
    end

    def generate_from_hash(hash, headers: true, col_sep: ";", **args)
      generate(col_sep: col_sep, **args) do |csv|
        write_hash_in_csv(csv, hash, headers)
      end
    end

    private

    def write_hash_in_csv(csv, hash, headers)
      csv << hash.first.keys.map { |key| key.to_s.tr("_", " ").capitalize } if headers && csv.count.zero?
      hash.each { |kvp| csv << kvp.values }
    end
  end
end
