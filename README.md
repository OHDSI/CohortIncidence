CohortIncidence
=====
[![Build Status](https://github.com/OHDSI/CohortIncidence/workflows/R-CMD-check/badge.svg)](https://github.com/OHDSI/CohortIncidence/actions?query=workflow%3AR-CMD-check)
[![codecov.io](https://codecov.io/github/OHDSI/CohortIncidence/coverage.svg?branch=master)](https://codecov.io/github/OHDSI/CohortIncidence?branch=master)

CohortIncidence is part of [HADES](https://ohdsi.github.io/Hades).

Introduction
============
An R package and Java library for calculating incidence rates on the OMOP CDM.


Features
========
- Handles specifications of T-O-TAR-Subgroup pairs, and performs the calculation on the cross-product of the elements.
- Specify clean windows to account for immortal time after outcome.
- Allows multiple exposure and multiple outcomes per person accounting for time at risk and clean window paramaters.

Technology
==========
CohortIncidence is an R package which wraps a Java library that implements most of the functions of the package.

System Requirements
===================
Requires R and Java.

Getting Started
===============

## R package

1. See the instructions [here](https://ohdsi.github.io/Hades/rSetup.html) for configuring your R environment, including Java.

2. In R, use the following commands to download and install CohortIncidence:

  ```r
  install.packages("remotes")
  library(remotes)
  install_github("ohdsi/CohortIncidence") 
  ```

## Java library

The Java library is hosted in an OHDSI Nexus repo, so you only need to add the repository and dependnecy to your maven.xml file in order to use it in your own Java project.

1. First add the OHDSI Nexus repository so that maven can find and download the artifact automatically:
```xml
  <repositories>
    <repository>
      <id>ohdsi</id>
      <name>repo.ohdsi.org</name>
      <url>https://repo.ohdsi.org/nexus/content/groups/public</url>
    </repository>
  </repositories>
```
2: Include the CohortIncidence dependency in your pom.xml
```xml
<dependency>
	<groupId>org.ohdsi.sql</groupId>
	<artifactId>CohortIncidence</artifactId>
	<version>{latest version}</version>
</dependency>
```

User Documentation
==================
Documentation can be found on the [package website](https://ohdsi.github.io/CohortIncidence).

PDF versions of the documentation are also available:
* Vignette: [Using CohortIncidence](https://raw.githubusercontent.com/OHDSI/CohortIncidence/master/vignettes/using-cohortincidence.pdf)

Support
=======
* Developer questions/comments/feedback: <a href="http://forums.ohdsi.org/c/developers">OHDSI Forum</a>
* We use the <a href="https://github.com/OHDSI/CohortIncidence/issues">GitHub issue tracker</a> for all bugs/issues/enhancements
 
Contributing
============
Read [here](https://ohdsi.github.io/Hades/contribute.html) how you can contribute to this package.

License
=======
CohortIncidence is licensed under Apache License 2.0

Development
===========
CohortIncidence is being developed in R Studio.

### Development status

Released, Under Active Development

