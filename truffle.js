module.exports = {
  migrations_directory: './migrations',
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      gasPrice: 20000000000,
      network_id: "*" // Match any network id
    },
    net42: {
      host: "localhost",
      port: 8545,
      network_id: "42"
    }
  }
};
