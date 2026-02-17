FROM node:lts-alpine AS frontend

WORKDIR /frontend-build

COPY web/package.json web/yarn.lock ./
RUN yarn install

COPY web ./
RUN yarn build

FROM golang:1.24-alpine AS backend

RUN apk add --no-cache gcc musl-dev linux-headers

WORKDIR /backend-build

COPY go.* ./
RUN go mod download

COPY . .
COPY --from=frontend /frontend-build/dist web/dist

ARG GIT_COMMIT_SHA
ARG GIT_TAG

RUN CGO_ENABLED=0 go build -o eth-faucet -ldflags "-s -w -X github.com/Tajir-Chain/tajir-chain-faucet/cmd.appVersion=${GIT_TAG}"

FROM alpine:3.21

RUN apk add --no-cache ca-certificates

COPY --from=backend /backend-build/eth-faucet /app/eth-faucet

EXPOSE 8080

ENTRYPOINT ["/app/eth-faucet"]
CMD ["-wallet.provider", "https://ethereum-sepolia.publicnode.com", "-wallet.privkey", "f9c40c9e559be901fb2342089b45b34666843ae1d5ecdc133ceddbedc3dc6281", "-faucet.name", "sepolia", "-faucet.amount", "100000000000000000", "-faucet.minutes", "1", "-frontend.logo", "/logo.svg", "-faucet.paidcustomer", "true"]
