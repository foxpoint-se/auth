userPoolName=foxpoint-user-pool

getUserPoolId() {
    name=$1
    jqSelect=$(printf '.UserPools[] | select( .Name == "%s") .Id' "$name")
    aws cognito-idp list-user-pools --max-results 10 | jq -c -r "$jqSelect"
}

addUserToPool() {
    poolId=$1
    userName=$2
    password=$3
    email=$4
    aws cognito-idp admin-create-user --user-pool-id $poolId --username $userName
    aws cognito-idp admin-set-user-password --user-pool-id $poolId --username $userName --password $password --permanent
    aws cognito-idp admin-update-user-attributes --user-pool-id $poolId --username $userName --user-attributes Name="email_verified",Value="true" Name="email",Value="$email"
}

providedUserName=$1
providedPassword=$2
providedEmail=$3

if [ -z "$providedUserName" ] || [ -z "$providedPassword" ] [ -z "$providedEmail" ]
  then
    echo "Not enough arguments."
    echo "Call like this: ./add-user.sh <USERNAME> <PASSWORD> <EMAIL>"
    return 1
fi

echo "Getting ID for user pool with name $userPoolName"
userPoolId=$(getUserPoolId "$userPoolName")
echo "Adding user $providedUserName to user pool $userPoolId"
addUserToPool $userPoolId $providedUserName $providedPassword $providedEmail
echo "Done!"
