module Cangaroo
  class ValidateJsonSchema
    include Interactor

    SCHEMA = {
      'id': 'Cangaroo Object',
      'type': 'object',
      'minProperties': 1,
      'additionalProperties': false,
      'patternProperties': {
        '^[a-z]*$': {
          'type': 'array',
          'items': {
            'type': 'object',
            'required': ['id'],
            'properties': {
              'id': {
                'type': 'string'
              }
            }
          }
        }
      }
    }.freeze

    before :prepare_context

    def call
      validation_response = JSON::Validator.fully_validate(SCHEMA, context.json_body)

      if validation_response.empty?
        return true
      end

      context.fail!(message: validation_response.join(', '), error_code: 500)
    end

    private

    def prepare_context
      context.request_id = context.json_body.delete('request_id')
      context.summary = context.json_body.delete('summary')
      context.parameters = context.json_body.delete('parameters')
    end
  end
end
