require 'spec_helper'

describe ActiveForce::SObject do
  let(:ability){ Ability.new }

  describe '#accessible_by' do
    let(:accessible_query){ Carlton.accessible_by(ability).to_s }
    let(:expected_query)  { "SELECT Id, Table_Flip_Label, Dance_Date_Label FROM Carlton__c WHERE #{where_clause}" }

    describe 'when an ability is NOT defined for the SObject' do
      let(:where_clause){ '(Id=NULL)' }

      it 'generates the right query' do
        accessible_query.must_equal(expected_query)
      end
    end

    describe 'when an unscoped ability is defined for the SObject' do
      let(:where_clause){ '(Id!=NULL)' }

      before{ ability.can :index, Carlton }

      it 'generates the right query' do
        accessible_query.must_equal(expected_query)
      end
    end

    describe 'when a scoped ability is defined for the SObject' do
      let(:where_clause){ '(Table_Flip_Label = true) AND (Dance_Date_Label = 2014-10-31T00:00:00+00:00)' }

      before{ ability.can :index, Carlton, table_flip: true, dance_date: DateTime.parse('31/10/2014') }

      it 'generates the right query' do
        accessible_query.must_equal(expected_query)
      end
    end

    describe 'when a scoped ability on a belongs_to association 2 levels deep is defined for the SObject' do
      let(:accessible_query)      { Moves.accessible_by(ability).to_s }
      let(:expected_query)        { "SELECT Id, Name_Label, Dance_Id__c FROM Moves__c WHERE (Name_Label = 'A Carlton Move') AND (Dance_Id__c IN ('#{dance_ids.join("','")}'))" }
      let(:dance_date)            { DateTime.parse('31/10/2014')  }
      let(:dance_client)          { MiniTest::Mock.new }
      let(:carlton_client)        { MiniTest::Mock.new }
      let(:dance_ids)             { ['hamhamhamhamham111','hamhamhamhamham222','hamhamhamhamham333'] }
      let(:carlton_ids)           { ['hamhamhamhamham444','hamhamhamhamham555','hamhamhamhamham666'] }
      let(:expected_carlton_query){ "SELECT Id FROM Carlton__c WHERE (Dance_Date_Label = #{dance_date.iso8601})" }
      let(:expected_dance_query)  { "SELECT Id FROM Dance__c WHERE (Name_Label = 'The Carlton Dance') AND (Carlton_Id__c IN ('#{carlton_ids.join("','")}'))" }

      before do
        ability.can(:index, Moves, name: 'A Carlton Move', dance: {name: 'The Carlton Dance', carlton: {dance_date: dance_date } })
      end

      it 'generates the right query' do
        Carlton.stub :sfdc_client, carlton_client do
          Dance.stub :sfdc_client, dance_client do

            carlton_client.expect :query, carlton_ids.map{|id| {'Id' => id} } do |carlton_query|
              carlton_query == expected_carlton_query
            end

            dance_client.expect :query, dance_ids.map{|id| {'Id' => id} } do |dance_query|
              dance_query == expected_dance_query
            end

            accessible_query.must_equal(expected_query)
          end
        end
      end
    end
  end
end