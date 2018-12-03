from setuptools import setup

setup(
    name='falce',
    version='0.1a',
    url='https://github.com/WEEE-Open/falce',
    license='GPLv3',
    author='a-porsia',
    author_email='',
    description='Build a custom ISO with JLIVECD without annoying interactive prompts',
    scripts=['falce'],
    requires=['pexpect']
)