module CanCanActiveForceAdapter
  class ActiveForceAdapter < CanCan::ModelAdapters::AbstractAdapter
    def self.for_class?(model_class)
      model_class <= ActiveForce::SObject
    end

    # Returns conditions intended to be used inside a database query. Normally you will not call this
    # method directly, but instead go through CanCan::ModelAdditions#accessible_by.
    #
    # If there is only one "can" definition, a hash of conditions will be returned matching the one defined.
    #
    #   can :manage, User, :id => 1
    #   query(:manage, User).conditions # => { :id => 1 }
    #
    # If there are multiple "can" definitions, a SQL string will be returned to handle complex cases.
    #
    #   can :manage, User, :id => 1
    #   can :manage, User, :manager_id => 1
    #   cannot :manage, User, :self_managed => true
    #   query(:manage, User).conditions # => "not (self_managed = 't') AND ((manager_id = 1) OR (id = 1))"
    #
    def conditions
      if @rules.size == 1 && @rules.first.base_behavior
        # Return the conditions directly if there's just one definition
        tableized_conditions(@rules.first.conditions).dup
      else
        @rules.reverse.inject(false_sql) do |sql, rule|
          merge_conditions(sql, tableized_conditions(rule.conditions).dup, rule.base_behavior)
        end
      end
    end

    def tableized_conditions(conditions, **opts)
      return conditions unless conditions.kind_of? Hash
      opts.reverse_merge! model_class: @model_class
      result_hash = conditions.inject({}) do |temp_hash, (name, value)|
        if value.kind_of? Hash
          value = value.dup
          association_class    = opts[:model_class].associations[name].relation_model
          association_sf_field = opts[:model_class].associations[name].foreign_key
          association_field    = opts[:model_class].mapping.mappings.select{|key, value| value == association_sf_field }.keys[0]

          # Merge Id's of records that can be accessed for the given association.
          # (e.g. {carlton_id: [1,2,3]})
          temp_hash[association_field] = tableized_conditions(value, model_class: association_class, query_ids_as: association_field)[association_field]
        else
          temp_hash[name] = value
        end

        temp_hash
      end

      if !!opts[:query_ids_as]
        result_hash[opts[:query_ids_as]] = opts[:model_class].select(:id).where(result_hash).map &:id
      end

      result_hash
    end

    def database_records
      c = conditions
      if c.blank?
        @model_class.where true_sql
      else
        @model_class.where(c)
        #@model_class.includes(included_conditions).where conditions
      end
    end

    private

    def merge_conditions(sql, conditions_hash, behavior)
      if conditions_hash.blank?
        behavior ? true_sql : false_sql
      else
        conditions = sanitize_sql(conditions_hash)
        case sql
        when true_sql
          behavior ? true_sql : "not (#{conditions})"
        when false_sql
          behavior ? conditions : false_sql
        else
          behavior ? "(#{conditions}) OR (#{sql})" : "not (#{conditions}) AND (#{sql})"
        end
      end
    end

    def false_sql
      sanitize_sql(['Id=?', nil])
    end

    def true_sql
      sanitize_sql(['Id!=?', nil])
    end

    def sanitize_sql(conditions)
      sql = Array(ActiveForce::ActiveQuery.new(@model_class).send(:build_condition, conditions))
      sql.join 'AND'
    end

    # Removes empty hashes and moves everything into arrays.
    def clean_joins(joins_hash)
      joins = []
      joins_hash.each do |name, nested|
        joins << (nested.empty? ? name : {name => clean_joins(nested)})
      end
      joins
    end
  end
end

ActiveForce::SObject.class_eval do
  include CanCan::ModelAdditions
end
