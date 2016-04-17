# HAProxy Configuration Generator

This project uses [AWS Lambda](https://aws.amazon.com/lambda/) and [API Gateway](https://aws.amazon.com/api-gateway/) to create an API endpoint that can be used to generate a `haproxy.cfg` file based on the parameters provided.

One major pain point of using Lambda and API Gateway is the difficulty of setting things up. This project uses Terraform to ease that difficulty.

You need to have [Terraform](https://www.terraform.io/) installed and a functioning [AWS](https://aws.amazon.com/) account to deploy this project.

You can run the project locally using [Lambda-local](https://github.com/ashiina/lambda-local).

## Usage

Follow these steps to deploy:

1. Install NPM modules: `npm install`
2. Compress the project: `zip -r haproxy_config_generator.zip .`.
3. Deploy the project by simply invoking `terraform apply`. You'll be asked for your AWS credentials. If you don't want to be prompted, you can add your credentials to the `variables.tf` file or run the setup using:
```bash
terraform apply -var 'aws_access_key={your_aws_access_key}' \
   -var 'aws_secret_key={your_aws_secret_key}'
```

To tear down:
```bash
terraform destroy
```

You can find the Invoke URL for the API created via the AWS console for API Gateway. The steps look like: `Amazon API Gateway | APIs > haproxy_config_generator > Stages > api`.

You can generate the config file by running these commands:
```bash
$ curl -o /tmp/haproxycfg -H "Content-Type: application/json" --data @sample-data/data.json <invoke_url>
$ echo "$(</tmp/haproxycfg)" > haproxy.cfg
$ rm /tmp/haproxycfg
```

### Customizing the Project

The Lambda handler expects an `event` with the structure documented in `index.js`. This structure is only relevant because the [Nunjucks](https://github.com/mozilla/nunjucks) template file (`template/haproxy.cfg.njk`) relies on it to interpolate values in the right places. You can pass in any `event` structure you want as long as you modify the Nunjucks template file to understand it.

## Notes

There is a [known issue](https://forums.aws.amazon.com/message.jspa?messageID=678324) whereby a newly deployed API Gateway would fail to call a Lambda function throwing an error similar to this one:
```bash
Execution failed due to configuration error: Invalid permissions on Lambda function
Method completed with status: 500
```
Or:
```bash
{
  "message": "Internal server error"
}
```
The solution for this is straightforward and demonstrated in [this youtube video](https://www.youtube.com/watch?v=H4LM_jw5zzs).
