# Outline



 - ....






# What is Conda?

- Conda is an open source package and environment management system 
- If you are installing it on your local machine you can pick between Miniconda and Anaconda 
- Conda can manage packages for a wide variety of programming languages but is most often used with python
- works well across multiple platforms (macOS, Windows, Linux)

# What are Conda Environments?

- Conda environments are isolated spaces maintained by created within Conda that allow users to use and manage different versions of Python and packages
- Each environment can have its own set of packages without affecting other environments
- Environemnts ensure reproducibility of code and help avoid conflicts between package versions

<center><img src="conda_illustration.png"></center>
(Image from https://nbisweden.github.io/excelerate-scRNAseq/conda_instructions.html)

# Conda Vs Mamba

- Mamba is a faster drop in replacement for conda which is implemented in c++ and takes advantage of parallel loading
- Mamba and Conda can be used interchangable just change the prefix conda to mamba for each command
  
  
# Why Should We Use Them?

- Dependency Management
  -  manage project specifiic dependencies without affecting other projects on the system
- Reproducibility
  - scientific computing
- Collaboration
  -  share environments with others
- Cross-Platform
  -  environments work the same way across operating systems


# Setting up Environments 

- In Savio a Conda Environment can be set up like such:

```bash
module load python
conda create --name=test_env python=3.10 numpy
```

- now let's do it in mamba, you can install mamba into a conda env as such:

```bash
conda install mamba -c conda-forge
```
- create a env using mamba command

```bash
mamba create -c conda-forge --name test_env2 python=3.10
```

# Activating and Adding to Environments

- Environments can be activated using `source activate` or `conda/mamba activate`
- `source` is reccemended on Savio as using conda activate might require the use of `conda init` which can alter ther shell behavior due to odifiying .bashrc conda may now attempt to start a base environment when logging into the shell causing slowdowns.
- if you do use conda init you can stop base environment setup with the following:
```bash
  conda config --set auto_activate_base False
```

- Let's activate our environemnt

```bash
source activate test_env
```
- to add to an environment we use the install command while in a environment

```bash
mamba install -c conda-forge scipy=1.4.1
```

- we now have scipy insalled in our environment we can set the version of scipy we want to match our project

```bash
source deactivate
```

# common commands, isolating envs, jupyter, pip etc ....