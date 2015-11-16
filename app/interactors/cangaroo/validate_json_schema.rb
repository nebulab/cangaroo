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

    def call
      JSON::Validator.fully_validate(SCHEMA, context.json_body).empty? ||
        context.fail!(message: 'wrong json schema', error_code: 500)
    end
  end
end
