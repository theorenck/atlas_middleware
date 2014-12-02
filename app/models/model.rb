class Model
  include ActiveModel::Model
  include ActiveModel::AttributeMethods
  include ActiveModel::SerializerSupport

  def self.attribute(name)
    attr_accessor name
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{name}?
        self.send(:#{name}).present?
      end
    CODE
  end
end