# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = 'CMSIS-RTOS V2 Ejemplos'
copyright = 'Universidad Politécnica de Madrid'
author = 'Mariano Ruiz'
release = '1.0'
version = '1.0'


# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['sphinx_simplepdf', 'myst_parser']

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']

simplepdf_vars = {
    'primary': '#a023fa',
    'secondary': '#379683',
    'cover': '#ffffff',
    'white': '#ffffff',
    'links': '#FA2323',
    'cover-overlay': 'rgba(250, 35, 35, 0.5)',
    'top-left-content': 'counter(page)',
    'bottom-center-content': 'string(heading)',
}

numfig = True
simplepdf_file_name = "SBM-CMSIS-RTOS-V2.pdf"

numfig_format = {
    'code-block': 'Listing %s',
    'figure': 'Fig. %s',
    'section': 'Section',
    'table': 'Table %s',
}