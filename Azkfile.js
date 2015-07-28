/**
 * Documentation: http://docs.azk.io/Azkfile.js
 */
// Adds the systems that shape your system
systems({
  insights: {
    // Dependent systems
    depends: [],
    // More images:  http://images.azk.io
    image: {"docker": "gullitmiranda/elixir"},
    // Steps to execute before running instances
    provision: [
      "mix do deps.get, compile",
    ],
    workdir: "/azk/#{manifest.dir}",
    command: "exit 0",
    mounts: {
      '/azk/#{manifest.dir}'        : sync("."),
      '/azk/#{manifest.dir}/deps'   : persistent("#{system.name}/deps"),
      '/azk/#{manifest.dir}/_build' : persistent("#{system.name}/_build"),
      '/azk/#{manifest.dir}/doc'    : persistent("#{system.name}/doc"),
      '/root/.hex/hex'              : persistent("#{system.name}/.hex"),
      '/root/.hex/hex.config'       : path(env.HOME + '/.hex/hex.config'),
    },
    scalable: false,
    http: false,
    wait: false,
    envs: {
      // Make sure that the PORT value is the same as the one
      // in ports/http below, and that it's also the same
      // if you're setting it in a .env file
      MIX_ENV: "test",
    },
  },
});
