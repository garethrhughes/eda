import { SQSEvent, SQSHandler } from "aws-lambda";

export const handler: SQSHandler = async (event: SQSEvent): Promise<void> => {
    console.log("Received event:", JSON.stringify(event, null, 2));

    for (const record of event.Records) {
        try {
            const messageBody: { Message: string } = JSON.parse(record.body);
            const message: { FileName: string, DocumentPath: string } = JSON.parse(messageBody.Message);

            console.log("Processing message:", message);

            const response = await fetch("https://bvok56gibmjfgaswfkdoairo6y0qfccj.lambda-url.ap-southeast-2.on.aws/documents", {
                method: "POST",
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ name: message.FileName, path: message.DocumentPath }),
            });

            const responseJson = await response.json();
            console.log('Result', responseJson);

        } catch (error) {
            console.error("Error processing message:", error, "Message:", record.body);
            // Optionally handle errors or move message to a dead-letter queue
        }
    }
}