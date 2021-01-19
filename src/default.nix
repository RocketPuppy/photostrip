{ buildPythonPackage, pythonPackages }:

buildPythonPackage rec {
  pname = "photostrip";
  version = "0.1.0";

  src = ./.;

  propagatedBuildInputs = with pythonPackages; [ flask Wand setuptools ];
}
