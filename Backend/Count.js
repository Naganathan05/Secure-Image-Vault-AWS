const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const tableName = 'visitor_count';

exports.handler = async (event) => {
    const httpMethod = event.httpMethod;

    if (httpMethod === 'POST') {
        try {
            const response = await dynamodb.get({
                TableName: tableName,
                Key: { id: '0' }
            }).promise();

            let count = response.Item.count;
            count++;

            await dynamodb.put({
                TableName: tableName,
                Item: { id: '0', count: count }
            }).promise();

            return {
                statusCode: 200,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
                },
                body: JSON.stringify({ message: `New view count: ${count}` })
            };
        } catch (err) {
            console.error(err);
            return {
                statusCode: 500,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
                },
                body: JSON.stringify({ error: 'Internal Server Error' })
            };
        }
    } else if (httpMethod === 'GET') {
        try {
            const response = await dynamodb.get({
                TableName: tableName,
                Key: { id: '0' }
            }).promise();

            const count = response.Item.count;

            return {
                statusCode: 200,
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'OPTIONS,GET',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ count: count })
            };
        } catch (err) {
            console.error(err);
            return {
                statusCode: 500,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
                },
                body: JSON.stringify({ error: 'Internal Server Error' })
            };
        }
    } else {
        return {
            statusCode: 405,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
            },
            body: JSON.stringify({ error: 'Method not allowed' })
        };
    }
};
