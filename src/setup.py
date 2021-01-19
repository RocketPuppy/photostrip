from setuptools import setup

setup(
    name='Photostrip',
    version='1.0',
    packages=['photostrip'],
    include_package_data=True,
    zip_safe=False,
    install_requires=['Flask', 'Wand']
)
