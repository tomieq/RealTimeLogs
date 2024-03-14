FROM swift:5.7 as builder
WORKDIR /app
COPY . .
RUN swift build -c release 
RUN echo $(ls -la .build | grep linux)

FROM swift:5.7-slim
RUN apt-get update -y
WORKDIR /app
COPY --from=builder /app/.build/x86_64-unknown-linux-gnu/release/RealTimeLogs .
CMD ["./RealTimeLogs"]