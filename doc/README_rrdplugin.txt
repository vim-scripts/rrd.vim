RRD PLUGIN

What is this Plugin?
--------------------

The RRD.vim package is a vim module that acts as a frontend to manipulating the
data from a round-robin database created by Tobi Oetiker's excellent RRDTool
program. RRDTool and documenation can be found on the URL:

 http://www.rrdtool.org/


Change Log:
-----------

 v1.1: Nov 04 2002
 * Added support for Adding and Deleting datasets
 * Changed foldtext function to pretty print the period of a dataset. RRA's are
   now shown with the sample rate and sample period. I.e.

   +- RRA: AVERAGE (sample 10 mins / 2 days) ------------------------
   +- RRA: AVERAGE (sample 30 mins / 8 days) ------------------------
   +- RRA: AVERAGE (sample 2 hrs / 28 days) ------------------------
   +- RRA: AVERAGE (sample 1 day / 370 days) ------------------------


Installing this Plugin:
-----------------------

You can read details on how this module works by reading the help documentation
that comes with it. To install the program and documentation copy the contents
of the zip file into your local vim directory (.vim on unix or vimfiles on
Windows) The contents of filetype_rrd.vim should be copied into your
filetype.vim file. Once you have the doc/rrd.txt file in your local docs
directory, install it as a Vim help doc using the :helptags command. I.e.

  :helptags $HOME/.vim/docs

What does this plugin offer?
----------------------------

With this plugin yuo can edit your RRD data in a comfortable environment which
will not only allow you to edit the text, but to see areas highlighted with
colours, and fold large blocks of data into single line notes. As of version
1.1 you can also add and remove entire datasets and their data.


Why you don't have to use this plugin:
--------------------------------------

Note that you do not have to fix spikes in your datafiles by rewriting
them in this fashion. You can make use of the CDEF rules when plotting your
graph to cap the values that are displayed. If you're not sure how to do this,
see Alex van den Bogaerdt's tutorial on the RRDTool web site:

 http://www.rrdtool.org/tutorial/cdeftutorial.html

 .. but this only applies to the graphing routines, so if you wanted to use the
data yourself for something else, you would have to correct the data in every
application that you write. Obviously this could become tedious, so this plugin
might be useful.

Why did I write this plugin?
----------------------------

I wrote this plugin for Vim for a couple of reasons:

 1) I wanted to be able to take the spikes out of some of the data that SNIPS
    polls from my servers and I was tired of converting it by hand only to find
    out I'd overwritten the latest data that SNIPS had added.

 2) I like playing at writing plugins for Vim because I get to learn more about
    Vim. One day I may have a real need to write one instead of just making my
    life easier :)
 3) I like syntax highlighting. Nothing is more useful than a screen full of
    colour to show you that everything is in the right place.

And I had the added bonus of learning how to use syntax-folding. Folding is
something I've had trouble with in the past and now know a little better. I've
even learnt to read the documentation on how to create syn-folds ... shame it
was after I posted to the Vim mailing list to ask a question. :-)


Questions?

E-mail me: Colin Keith <vim at ckeith.clara.net>

