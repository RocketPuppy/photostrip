# Photostrip

Submit some images and make a photostrip!
No images are saved server side.

## Running

Requires ImageMagick 7 and Python 3.8.
Uses python packages: Wand 0.6.5, flask 1.1.2.

This app uses Nix to set up a development environment.
To run the app in development mode, do the following:

```
$ ./python -m flask run
```

You will need a nix-channel for `nixos-unstable` set up locally.
To do this, run:

```
$ nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
```
