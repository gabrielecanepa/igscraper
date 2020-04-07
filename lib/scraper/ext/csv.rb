# rubocop:disable Naming/MethodParameterName

require "csv"

class CSV
  class << self
    def insert_rows(filepath, h, headers: true, col_sep: ";", **args)
      self.open(filepath, "a+", col_sep: col_sep, **args) do |csv|
        write_hash_in_csv(csv, h, headers)
      end
    end

    def from_h(h, headers: true, col_sep: ";", **args)
      generate(col_sep: col_sep, **args) do |csv|
        write_hash_in_csv(csv, h, headers)
      end
    end

    private

    def write_hash_in_csv(csv, h, headers)
      csv << h.first.keys.map { |key| key.to_s.tr("_", " ").capitalize } if headers && csv.count.zero?
      h.each { |kvp| csv << kvp.values }
    end
  end
end

# rubocop:enable Naming/MethodParameterName
