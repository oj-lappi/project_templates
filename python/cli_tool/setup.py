from setuptools import setup

def readme():
    with open('README.md') as f:
        return f.read()

setup(name='{{project_name}}',
    version='0.1',
    description='{{project_name}}, does a thing',
    long_description=readme(),
    #url='http://github.com/oj-lappi/{{project_name}}',
    author='Oskar Lappi',
    #author_email='oskar.lappi@abo.fi',
    license='MIT',
    packages=['{{project_name}}'],
    #install_requires=['pandas'],
    entry_points={'console_scripts':['{{project_name}}={{project_name}}.cmd:main']},
    zip_safe=False)
