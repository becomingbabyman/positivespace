module ActiveRecordExtensions
	extend ActiveSupport::Concern

	module ClassMethods
		def map_accessible_attributes
			accessible_attributes = self.accessible_attributes.to_a.reject!(&:empty?)
			accessible_attributes_with_type = self.columns.map { |column| { name: column.name, type: column.type } if accessible_attributes.include? column.name }.compact
			accessible_attributes_with_type
		end
	end
end
