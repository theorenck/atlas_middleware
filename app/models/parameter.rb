class Parameter < ActiveType::Object

  after_initialize :evaluate, :formmat
  
  attribute :name
  attribute :value
  attribute :type
  attribute :evaluated

  enum type: [ :varchar, :integer, :decimal, :date, :time, :timestamp]
  
  validates_presence_of :name
  validates_presence_of :type
  validates_presence_of :value

  def evaluate
    if evaluated
      self.value = eval(value)
    end
  end

  def formmat
    if date? and evaluated?
      self.value = value.strftime("%Y-%m-%d")
    end
    if time? and evaluated?
      self.value = value.strftime("%H:%M:%S")
    end
    if timestamp? and evaluated?
      self.value = value.strftime("%Y-%m-%d %H:%M:%S")
    end
    if date?
      self.value = "{D '#{value}'}"
    end
    if time?
      self.value = "{T '#{value}'}"
    end
    if timestamp?
      self.value = "{TS '#{value}'}"
    end
    if varchar?
      self.value = "'#{value}'"
    end
  end
end
