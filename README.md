### Launch the board

```
docker run -it \
    -e OPENWEATHER_API_KEY=$OPENWEATHER_API_KEY \
    -e MOBISPRING_URL=$MOBISPRING_URL \
    -p 3030:3030 \
    pingu/homeboard
```
