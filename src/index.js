'use strict';

module.exports.handler = async (event, context) => {
  console.log({event})
  console.log('Records', JSON.stringify(event.Records))

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Rodou em TF!!!' })
  }
}
