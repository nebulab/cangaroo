module Cangaroo
  class ValidateJsonSchema
    include Interactor

    SCHEMA = {
      'type': 'object',
      'minProperties': 1,
      'additionalProperties': false,
      'patternProperties': {
        '^[a-z]*$': {
          'type': 'array',
          'minItems': 1,
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
      JSON::Validator.fully_validate(SCHEMA, context.json_body).empty? ||
        context.fail!(message: 'wrong json schema', error_code: 500)
    end

    private

    def prepare_context
      context.request_id = context.json_body.delete('request_id')
      context.summary = context.json_body.delete('summary')
    end
  end
end
