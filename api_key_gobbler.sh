#!/bin/bash
# By CodeNeko
# To attempt to extract any possible api keys from whatever (in this case firmware)
# regex helpfully obtained from https://github.com/h33tlit/secret-regex-list

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <folder> <outputfile>"
    exit 1
fi
folder_path="$1"
output_file="$2"

Cloudinary="cloudinary://.*"
FirebaseURL=".*firebaseio\.com"
SlackToken="(xox[p|b|o|a]-[0-9]{12}-[0-9]{12}-[0-9]{12}-[a-z0-9]{32})"
RSAprivatekey="\-\-\-\-\-BEGIN\ RSA\ PRIVATE\ KEY\-\-\-\-\-"
SSH_DSA_privatekey="\-\-\-\-\-BEGIN\ DSA\ PRIVATE\ KEY\-\-\-\-\-"
SSH_EC_privatekey="\-\-\-\-\-BEGIN\ EC\ PRIVATE\ KEY\-\-\-\-\-"
PGPprivatekeyblock="\-\-\-\-\-BEGIN\ PGP\ PRIVATE\ KEY\ BLOCK\-\-\-\-\-"
AmazonAWSAccessKeyID="AKIA[0-9A-Z]{16}"
AmazonMWSAuthToken="amzn\\.mws\\.[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
AWSAPIKey="AKIA[0-9A-Z]{16}"
FacebookAccessToken="EAACEdEose0cBA[0-9A-Za-z]+"
FacebookOAuth="[f|F][a|A][c|C][e|E][b|B][o|O][o|O][k|K].*['|\"][0-9a-f]{32}['|\"]"
GitHub="[g|G][i|I][t|T][h|H][u|U][b|B].*['|\"][0-9a-zA-Z]{35,40}['|\"]",
GenericAPIKey="[a|A][p|P][i|I][_]?[k|K][e|E][y|Y].*['|\"][0-9a-zA-Z]{32,45}['|\"]"
GenericSecret="[s|S][e|E][c|C][r|R][e|E][t|T].*['|\"][0-9a-zA-Z]{32,45}['|\"]"
GoogleAPIKey="AIza[0-9A-Za-z\\-_]{35}"
GoogleCloudPlatformAPIKey="AIza[0-9A-Za-z\\-_]{35}"
GoogleCloudPlatformOAuth="[0-9]+-[0-9A-Za-z_]{32}\\.apps\\.googleusercontent\\.com"
GoogleDriveAPIKey="AIza[0-9A-Za-z\\-_]{35}"
GoogleDriveOAuth="[0-9]+-[0-9A-Za-z_]{32}\\.apps\\.googleusercontent\\.com"
Google_GCP_Serviceaccount="\"type\": \"service_account\""
GoogleGmailAPIKey="AIza[0-9A-Za-z\\-_]{35}"
GoogleGmailOAuth="[0-9]+-[0-9A-Za-z_]{32}\\.apps\\.googleusercontent\\.com"
GoogleOAuthAccessToken="ya29\\.[0-9A-Za-z\\-_]+"
GoogleYouTubeAPIKey="AIza[0-9A-Za-z\\-_]{35}"
GoogleYouTubeOAuth="[0-9]+-[0-9A-Za-z_]{32}\\.apps\\.googleusercontent\\.com"
HerokuAPIKey="[h|H][e|E][r|R][o|O][k|K][u|U].*[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}"
MailChimpAPIKey="[0-9a-f]{32}-us[0-9]{1,2}"
MailgunAPIKey="key-[0-9a-zA-Z]{32}"
PasswordinURL="[a-zA-Z]{3,10}://[^/\\s:@]{3,20}:[^/\\s:@]{3,20}@.{1,100}[\"'\\s]"
PayPalBraintreeAccessToken="access_token\\\$production\\$[0-9a-z]{16}\\$[0-9a-f]{32}"
PicaticAPIKey="sk_live_[0-9a-z]{32}"
SlackWebhook="https://hooks.slack.com/services/T[a-zA-Z0-9_]{8}/B[a-zA-Z0-9_]{8}/[a-zA-Z0-9_]{24}"
StripeAPIKey="sk_live_[0-9a-zA-Z]{24}"
StripeRestrictedAPIKey="rk_live_[0-9a-zA-Z]{24}"
SquareAccessToken="sq0atp-[0-9A-Za-z\\-_]{22}"
SquareOAuthSecret="sq0csp-[0-9A-Za-z\\-_]{43}"
TwilioAPIKey="SK[0-9a-fA-F]{32}"
TwitterAccessToken="[t|T][w|W][i|I][t|T][t|T][e|E][r|R].*[1-9][0-9]+-[0-9a-zA-Z]{40}"
TwitterOAuth="[t|T][w|W][i|I][t|T][t|T][e|E][r|R].*['|\"][0-9a-zA-Z]{35,44}['|\"]"


variable_names=("Cloudinary" "FirebaseURL" "SlackToken" "RSAprivatekey" "SSH_DSA_privatekey" "SSH_EC_privatekey" "PGPprivatekeyblock" "AmazonAWSAccessKeyID" "AmazonMWSAuthToken" "AWSAPIKey" "FacebookAccessToken" "FacebookOAuth" "GitHub" "GenericAPIKey" "GenericSecret" "GoogleAPIKey" "GoogleCloudPlatformAPIKey" "GoogleCloudPlatformOAuth" "GoogleDriveAPIKey" "GoogleDriveOAuth" "Google_GCP_Serviceaccount" "GoogleGmailAPIKey" "GoogleGmailOAuth" "GoogleOAuthAccessToken" "GoogleYouTubeAPIKey" "GoogleYouTubeOAuth" "HerokuAPIKey" "MailChimpAPIKey" "MailgunAPIKey" "PasswordinURL" "PayPalBraintreeAccessToken" "PicaticAPIKey" "SlackWebhook" "StripeAPIKey" "StripeRestrictedAPIKey" "SquareAccessToken" "SquareOAuthSecret" "TwilioAPIKey" "TwitterAccessToken" "TwitterOAuth")
temp_file=$(mktemp)

for var in "${variable_names[@]}"; do
    value=${!var}
    # variable name: $var
    # variable value: $value
    echo "Searching for $var"
    grep -rhPo "$value" "$folder_path" > "$temp_file"
done

# sort "$temp_file" | uniq > "$output_file"
cat "$temp_file" | uniq > "$output_file"
rm "$temp_file"
echo "Deduplicated results saved to $output_file"