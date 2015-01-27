class Result < ActiveType::Object
  
  attribute :records
  attribute :fetched
  attribute :columns
  attribute :rows

  def to_h
    { 
      result: {
        records: records,
        fetched: fetched,
        columns: columns || [],
        rows: rows || []
      }
    }
  end
end