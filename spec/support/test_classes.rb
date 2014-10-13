module TestClasses
  class Ability
    include CanCan::Ability
    def intialize;end
  end

  class Carlton < ActiveForce::SObject
    field :table_flip, from: 'Table_Flip_Label', as: :boolean
    field :dance_date, from: 'Dance_Date_Label', as: :datetime
  end

  class Dance < ActiveForce::SObject
    field :name,       from: 'Name_Label'
    field :carlton_id, from: 'Carlton_Id__c'

    belongs_to :carlton, model: Carlton, foreign_key: 'Carlton_Id__c'
  end

  class Moves < ActiveForce::SObject
    field :name,       from: 'Name_Label'
    field :dance_id,   from: 'Dance_Id__c'

    belongs_to :dance, model: Dance, foreign_key: 'Dance_Id__c'
  end
end