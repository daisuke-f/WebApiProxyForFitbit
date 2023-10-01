# Requirements for local dev

- azure-functions-core-tools
- azurite

# How to run it

## Register your app
https://dev.fitbit.com/apps

## Retrieve initial tokens
https://dev.fitbit.com/build/reference/web-api/troubleshooting-guide/oauth2-tutorial/

## Launch Azure Function apps

```
func start
```

## Save the initial tokens in Blob

```
curl --include --request POST --header "Content-Type: application/json" --data '{"access_token":"...","refresh_token":"..."}' http://localhost:7071/api/InitTokenBlob
```

## Wait for automatically refreshing tokens once a hour.

## Or trigger it manually

```
curl --include --request POST --header "Content-Type: application/json" --data '{}' http://localhost:7071/admin/functions/TokenUpdater
```