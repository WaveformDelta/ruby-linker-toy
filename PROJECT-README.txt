PROJECT DESCRIPTION
===================

This is a project for working with the book "Linkers and Loaders" by John R. Levine, which describes the issues involved in writing linkers and loaders for binary object code in computer systems.  The complete text of the book can be found online at: http://www.iecc.com/linker/

The book includes an ongoing project at the end of each chapter: building a 'functional' linker and adding features as the book continues.  I place 'functional' in quotes because the object file format in question is just a structured text file in a defined format.  Nonetheless, the format captures the salient features of 'real' object files, and has the advantage that such files can be quickly created and modified in a text editor.

It also has the advantage that the linker can be implemented in a high-level scripting language.  Levine suggests using Perl, which was popular at the time (2001)--and to be fair, is still popular.  I chose to use Ruby, mostly because I wanted to become more familiar with it.  Ruby is at least as well-suited to the task as Perl, and also offers better support for object-oriented features.

This was important, because I also wanted to experiment with a more OO approach to developing a linker, and perhaps to play with design patterns a bit.  It seems that the terms 'object' in 'object file' and 'object' in 'object oriented' have nothing to do with each other; I wonder if that coincidental usage hides a pattern that can be exploited.

Levine had planned to provide working solutions to each exercise, but it seems he never completed this task: the official web site for the book (http://linker.iecc.com/) includes a page with Perl code for projects 3-1 through 4-3 (note that the projects don't start until chapter 3) and a promise, "Subsequent chapters to be added shortly."  These subsequent chapters have never appeared; I remember seeing a message board post somewhere that the poster had contacted Levine, who said it was unlikely that the remaining chapter projects would ever be completed, although I cannot locate that post now.  This seems to be an invitation to do it myself.  Note that I have studied Levine's Perl code thoroughly, and my early check-ins may amount to rewriting his code in a Ruby idiom.

My plan is to gradually develop the code, completing each project exercise and committing the results to my Git archive, which will be made available on GitHub at some point.  I will also comment on my discoveries and revelations in this file.

A few technical notes...

Git Usage
---------
I will maintain all code and test data for this project in a Git repo.  The master branch represents the ongoing state of the project.  A branch will be created for each chapter, named after the chapter.  I will use small-grained commits and provide detailed description in the commit message; as each project is completed (there are multiple projects per chapter), the summary line for the commit will highlight this milestone.  Since the chapter projects are cumulative, each branch will be merged into master and a new branch created at the start of each chapter.

Each commit will consist of functioning code, unless noted in the commit message.  For pedagogical purposes, mistakes will be left in the repo and noted in the commit log as they are repaired.

Directory Structure and Test Data
---------------------------------
Because the project should consist of only a few files, the directory structure is relatively simply.  All code lives in *.rb files at the root directory.  Test data in the form of linkable object files lives in the obj directory, where it has been placed by the 'compiler'.  This layout will be revised once I implement libraries, which require some extra directories.

Linkable input files form test data for the code.  Simple linkable object files for input to the linker use the extension '.lk' (for 'link'); generated output files use the extension '.ld' (for 'load').  File based libraries use the extension '.lib'.  See project 3.1 in the text an explanation of the file format.

Commentary
----------
Comments will go in this file, marked by date and time.  They will supplement the actual Git commit messages, and should be read along with them.  Comments here will be tied to the relevant Git commit ID when necessary.

Bon Appetit!!

WaveformDelta
11/23/2012
