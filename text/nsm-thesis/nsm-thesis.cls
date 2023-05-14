%% nsm-thesis.cls
%% Copyright (C) 2009-2020 Christoph Sommer <sommer@cms-labs.org>

%
% License (pick one or both):
% - Creative Commons Attribution-Share Alike 3.0 (or later)
% - GPL v2 (or later)
%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nsm-thesis}[2021/11/16 The NSM Thesis Class]  % YYYY/MM/DD


% -----------------------------------------------------------------------------
% Class options
% -----------------------------------------------------------------------------
\RequirePackage{ifthen}

% [germanthesis] - Thesis is written in German
\newboolean{germanthesis}
\setboolean{germanthesis}{false}
\DeclareOption{germanthesis}{\setboolean{germanthesis}{true}}

% [plainunnumbered] - Don't print numbers on plain pages
\newboolean{plainunnumbered}
\setboolean{plainunnumbered}{false}
\DeclareOption{plainunnumbered}{\setboolean{plainunnumbered}{true}}

% [earlydraft] - Settings for quick draft printouts
\newboolean{earlydraft}
\setboolean{earlydraft}{false}
\DeclareOption{earlydraft}{\setboolean{earlydraft}{true}}

% [watermark] - Print current time/date at bottom of each page
\newboolean{watermark}
\setboolean{watermark}{false}
\DeclareOption{watermark}{\setboolean{watermark}{true}}

% [phdthesis] - switch to PhD thesis style
\newboolean{phdthesis}
\setboolean{phdthesis}{false}
\DeclareOption{phdthesis}{\setboolean{phdthesis}{true}}

% [twoside] - double sided
\newboolean{oneside}
\setboolean{oneside}{true}
\DeclareOption{twoside}{\setboolean{oneside}{false}}

% [cutmargins] - text body fills complete page
\newboolean{cutmargins}
\setboolean{cutmargins}{false}
\DeclareOption{cutmargins}{\setboolean{cutmargins}{true}}

\ProcessOptions \relax
% -----------------------------------------------------------------------------


% -----------------------------------------------------------------------------
% Basics
% -----------------------------------------------------------------------------
% This class is based on report
\ifthenelse{\boolean{oneside}}{
\LoadClass[a4paper,10pt,onecolumn,oneside,openright]{report}
}{
\LoadClass[a4paper,10pt,onecolumn,twoside,openright]{report}
}
\ifthenelse{\boolean{cutmargins}}{
\RequirePackage[paperwidth=365pt,paperheight=618pt,textwidth=345pt,textheight=598pt,bindingoffset=0cm,marginparwidth=3.75cm,hmarginratio=1:1,vmarginratio=1:1]{geometry}
}{
\RequirePackage[a4paper,textwidth=345pt,textheight=598pt,bindingoffset=0cm,marginparwidth=3.75cm,hmarginratio=1:1,vmarginratio=1:1]{geometry}
}

% 150 percent line spacing
\RequirePackage{setspace}
\onehalfspacing

% Allow more (and larger) floats on text pages
\renewcommand{\topfraction}{0.9}  % use up to ..% of space on top
\renewcommand{\bottomfraction}{0.8}  % use up to ..% of space on bottom
\setcounter{topnumber}{4} % place up to .. on top
\setcounter{bottomnumber}{4} % place up to .. on bottom
\setcounter{totalnumber}{4} % place up to .. total
\renewcommand{\textfraction}{0.07} % allow down to ..% of text
\renewcommand{\floatpagefraction}{0.7} % fill at least ..% of float pages (must be less than \topfraction)

% Avoid widows and orphans (single line on bottom or top of page, respectively) at almost any cost
\clubpenalty = 10000
\widowpenalty = 10000
%\raggedbottom

% Default fonts
\newcommand{\mypageheadfont}{\normalfont}
\newcommand{\myheadingfont}{\normalfont}
%\RequirePackage[osf]{libertine}  % Linux Libertine
%\renewcommand{\mypageheadfont}{\normalfont\libertine}
%\renewcommand{\myheadingfont}{\normalfont\libertine}
\RequirePackage{lmodern}  % TT: Latin Modern
\RequirePackage{helvet}  % SF: Helvetica 
\RequirePackage[bitstream-charter,sfscaled=false]{mathdesign}  % RM: Bitstream Charter
% TODO: nicer math font?

% More encoding and typesetting fixes and tweaks
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{textcomp}
\ifthenelse{\boolean{earlydraft}}{
}{
    \RequirePackage[babel]{microtype}
}
\RequirePackage{hyphenat}

% Graphics insertion and filetypes' order of precedence
\RequirePackage[pdftex]{graphicx}
\pdfminorversion=7
\DeclareGraphicsRule{.out.png}{png}{.out.png}{}
\ifthenelse{\boolean{earlydraft}}{
    \DeclareGraphicsExtensions{.thumb.jpg,.out.png,.pdf,.png,.jpg}
    \DeclareGraphicsRule{.thumb.jpg}{jpg}{.thumb.jpg}{}
}{
    \DeclareGraphicsExtensions{.out.png,.pdf,.png,.jpg}
}

% Typesetting URLs
\RequirePackage[lowtilde,hyphens]{url}
\urlstyle{tt}
\g@addto@macro\UrlSpecials{%
    % re-define character '!' to insert a hard line break
    \do\!{\raisebox{0ex}[0ex][0ex]{\color{gray}\ensuremath{\searrow}}\newline}%
}

% For hyperref<->algorithm interaction
\RequirePackage{float}

% Cross-references are clickable
\RequirePackage[pdftex,bookmarks=true,bookmarksnumbered=true,colorlinks=false,pdfdisplaydoctitle=true,breaklinks=true]{hyperref}

% Captions
\RequirePackage[font=small, labelfont=bf, labelsep=endash, margin=1cm]{caption}

% Subfigures
\RequirePackage[margin=0cm]{subfig}

% Citations
\RequirePackage{csquotes}
\RequirePackage[style=ieee,doi=true,isbn=false,url=false,mincitenames=1,maxcitenames=3,minbibnames=10,maxbibnames=10]{biblatex}
\DeclareFieldFormat{title}{#1} % never apply title casing, even if bibtex field is unprotected
\DeclareFieldFormat{sentencecase}{#1} % never apply sentence casing, even if bibtex field is unprotected
\RequirePackage{xpatch}
\xpatchbibmacro{textcite}{\addspace}{\addnbspace}{}{}
\xpatchbibmacro{Textcite}{\addspace}{\addnbspace}{}{}
\DefineBibliographyStrings{english}{
    andothers = et~al\adddot\addspace
}
\defbibheading{bibliography}[\bibname]{%
    \chapter*{#1}%
    \addcontentsline{toc}{chapter}{#1}%
    \chaptermark{#1}%
}
\bibliography{references}

% The "SI" and "num" commands for typesetting units
\RequirePackage[range-phrase={\dots\,},per-mode=symbol,detect-all,forbid-literal-units]{siunitx}
\@ifpackagelater{siunitx}{2021-05-17}{
    % reinstate column type "s" (unit-only)
    \usepackage{collcell}
    \newcolumntype{s}{>{\collectcell\unit}c<{\endcollectcell}}
}{
}
\ifthenelse{\boolean{germanthesis}}{
    \sisetup{locale=DE}
}{
}
\AtBeginDocument{
\DeclareSIUnit\bit{bit}
\DeclareSIUnit\byte{Byte}
\DeclareSIUnit\decibelm{dBm}
\DeclareSIUnit\mph{mph}
}

% Commands for beautiful tables
\RequirePackage{booktabs}

% Equation typesetting fixes and tweaks + proof/theorem environment
\RequirePackage{amsmath}
\RequirePackage{amsthm}
\newtheorem{thm}{Theorem}[section]

% Allow list iteration over comma separated parameters
\RequirePackage{pgf}
\RequirePackage{pgffor}

% -----------------------------------------------------------------------------


% -----------------------------------------------------------------------------
% Internationalization support
% -----------------------------------------------------------------------------

% Multi-language support using Babel
\ifthenelse{\boolean{germanthesis}}{
    \RequirePackage[shorthands=off,american,ngerman]{babel}
}{
    \RequirePackage[shorthands=off,ngerman,american]{babel}
}

% % Don't indent paragraphs in german theses. Instead, leave blank space between paragraphs.
% \ifthenelse{\boolean{germanthesis}}{
%     \RequirePackage{parskip}
% }{
% }

% Time and date functions
\RequirePackage{datetime}
\newdateformat{germandateformat}{%
    \THEDAY{}. \monthnamengerman[\THEMONTH]{} \THEYEAR{}%
}
\newdateformat{americandateformat}{%
    \THEDAY{} \monthnameamerican[\THEMONTH]{} \THEYEAR{}%
}

% Clever References
\ifthenelse{\boolean{germanthesis}}{
    \RequirePackage[ngerman]{cleveref}[2009/17/04]
    \def\cref{\Cref}
    \def\crefrange{\Crefrange}
    \crefname{lstlisting}{Listing}{Listings}
    \Crefname{lstlisting}{Listing}{Listings}
    \crefname{listing}{Listing}{Listings}
    \Crefname{listing}{Listing}{Listings}
    \crefname{algorithm}{Algorithmus}{Algorithmen}
    \Crefname{algorithm}{Algorithmus}{Algorithmen}
}{
    \RequirePackage{cleveref}[2009/17/04]
    \def\cref{\Cref}
    \def\crefrange{\Crefrange}
    \crefname{lstlisting}{listing}{listings}
    \Crefname{lstlisting}{Listing}{Listings}
    \crefname{listing}{listing}{listings}
    \Crefname{listing}{Listing}{Listings}
    \crefname{algorithm}{algorithm}{algorithms}
    \Crefname{algorithm}{Algorithm}{Algorithms}
}

% Some more language-dependent commands
\ifthenelse{\boolean{germanthesis}}{
    \newcommand{\glossarytitlename}{Abkürzungsverzeichnis}
}{
    \newcommand{\glossarytitlename}{List of Abbreviations}
}

% Language-independent timestamp
\newcommand{\timestamp}{\renewcommand{\dateseparator}{-}\yyyymmdddate\today\quad\settimeformat{hhmmsstime}\currenttime}

% -----------------------------------------------------------------------------


% -----------------------------------------------------------------------------
% All the simple stuff goes here
% -----------------------------------------------------------------------------

% Show overfull boxes
\overfullrule 5pt

% The Enumerate package
\RequirePackage{enumitem}

% The Acronym package
\RequirePackage{acro}

\@ifpackagelater{acro}{2020/04/29}{
\NewDocumentCommand\acrodef{mO{#1}mG{}}{\DeclareAcronym{#1}{short={#2}, long={#3}, #4}}
% Set up Acronyms for Enumerate
\newlist{acronyms}{description}{1}
\setlist[acronyms]{
    labelwidth=7em,
    leftmargin=7.5em,
    noitemsep,
    itemindent=0pt,
}
\NewAcroTemplate[list]{acronyms}{%
  \acroheading
  \acropreamble
  \begin{acronyms}
    \acronymsmapF{%
      \item[\acrowrite{short}\acroifT{alt}{/\acrowrite{alt}}]
        \acrowrite{list}%
        \acroifT{foreign}{ (\acrowrite{foreign})}%
        \acroifT{extra}{, \acrowrite{extra}}%
        \acropagefill
        \acropages
          {\acrotranslate{page}\nobreakspace}
          {\acrotranslate{pages}\nobreakspace}%
      }
      {\item\AcroRerun}
  \end{acronyms}
}
\acsetup{list/heading={chapter*},list/name={\glossarytitlename},list/template=acronyms,format/extra={\emph}}
}{
\@ifpackagelater{acro}{2019/02/17}{
    % work around bug in 2019/02/17
    \NewDocumentCommand\acrodef{mO{#1}mG{}}{\DeclareAcronym{#1}{short={#2}, long={#3}, foreign-plural={}, #4}}
}{
    \NewDocumentCommand\acrodef{mO{#1}mG{}}{\DeclareAcronym{#1}{short={#2}, long={#3}, #4}}
}
% Set up Acronyms for Enumerate
\newlist{acronyms}{description}{1}
\setlist[acronyms]{
    labelwidth=7em,
    leftmargin=7.5em,
    noitemsep,
    itemindent=0pt,
}
\DeclareAcroListStyle{acronyms}{list}{list=acronyms}
\acsetup{list-heading={chapter*},list-name={\glossarytitlename},list-style=acronyms,extra-style=comma,extra-format={\emph}}
}

% Make automatically inserted "blank pages" really blank
\RequirePackage{emptypage}

% Fix spacing around "..."
\RequirePackage{ellipsis}

% TeX ist kein Zeichenprogramm
\RequirePackage{tikz}[2010/10/13]
\usetikzlibrary{}

% Ensure that no floats are typeset before they are referenced
\RequirePackage{flafter}

% Provide the \FloatBarrier command that flushes all pending floats
\RequirePackage{placeins}

% Nag about deprecated LaTeX packages and commands
\RequirePackage[l2tabu, orthodox]{nag}

% Define command that will return current filename
\RequirePackage{currfile}

% Do not reset footnote counter on new chapter
\RequirePackage[]{chngcntr}
\counterwithout{footnote}{chapter}

% "Draft" watermark
\newcommand{\thewatermark}{\ifthenelse{\boolean{watermark}}{%
    \begin{tikzpicture}[remember picture, overlay]
        \node[anchor=south, outer sep=3.75cm] at (current page.south) {
            \color{gray}\currfilename\quad\timestamp
        };
    \end{tikzpicture}%
}{}}

% The "algorithm" environment
\RequirePackage{algorithmic}[2009/08/24]
\RequirePackage[plain,chapter]{algorithm}
\floatplacement{algorithm}{bp}

% The "syntax" environment
\RequirePackage[nounderscore,rounded]{syntax}

\renewcommand\fs@plain{%
\def\@fs@cfont{\rmfamily}%
\let\@fs@capt\floatc@plain%
\def\@fs@pre{\hrule\relax\kern2pt}%
\def\@fs@post{}%
\def\@fs@mid{\kern2pt\hrule\relax\vspace\abovecaptionskip\relax}%
\let\@fs@iftopcapt\iffalse%
}
\floatstyle{plain}
\restylefloat{algorithm}
\ifthenelse{\boolean{germanthesis}}{
    \floatname{algorithm}{Algorithmus}
}{
}

% Chapter/section headings and page styles
%\RequirePackage[pagestyles,nobottomtitles*]{titlesec}
\RequirePackage[pagestyles]{titlesec}

% Work around bug in titlesec version 2.10.1
\@ifpackagelater{titlesec}{2016/03/21}{}{\@ifpackagelater{titlesec}{2016/03/15}{%
    \def\ttlh@hang#1#2#3#4#5#6#7#8{%
    \gdef\ttl@makeline##1{\ttl@calc\hspace{#6}##1\ttl@calc\hspace{#7}}%
    \setlength\leftskip{#6}%
    \setlength\rightskip{#7}%
    \interlinepenalty\@M
    \ttl@changecentercr
    \ttl@beginlongest
    #1{\ifhmode\ttl@hmode@error\fi
         \ttl@glcmds
         \parindent\z@
         \begingroup
             \ifttl@label
                    \noindent
                    \sbox\z@{#2\strut\ttl@calc\hspace{#3}}%
                    \hangindent\wd\z@
                    \box\z@
             \fi
             #4{#8}%
             \kern\z@\strut\@@par
         \endgroup
         \nobreak\ttl@midlongest#5\@@par}%
    \ttl@endlongest}
}{}}

\ifthenelse{\boolean{plainunnumbered}}{
\renewpagestyle{plain}{%
    \sethead{}{}{}
    \setfoot{}{}{\thewatermark}
}
}{
\renewpagestyle{plain}{%
    \sethead{}{}{}
    \setfoot{}{\mypageheadfont\thepage}{\thewatermark}
}
}

% Pagestyle "fancy"
\newpagestyle{fancy}{%
\sethead*{
    \bfseries
    \toptitlemarks
    \mypageheadfont\bfseries
    \ifthechapter
        {
            \ifthesection
            {\firsttitlemarks\thesection~\sectiontitle}
            {\thechapter~\chaptertitle}
        }
        {\chaptertitle}
}
{}{\mypageheadfont\bfseries\thepage}
    \setfoot{}{}{\thewatermark}
    \headrule
}
\pagestyle{fancy}

% rename (sub)paragraph to (sub)subsubsubsection
\let\myparagraph\paragraph
\renewcommand{\paragraph}{\FIXME{in order to avoid confusion with hyperref, \\paragraph has been renamed to \\subsubsubsection}}
\let\subsubsubsection\myparagraph
\let\mysubparagraph\subparagraph
\renewcommand{\subparagraph}{\FIXME{in order to avoid confusion with hyperref, \\subparagraph has been renamed to \\subsubsubsubsection}}
\let\subsubsubsubsection\mysubparagraph

% heading styles
\titleformat{\chapter}[display]{\setlength\parskip{0pt}\myheadingfont\huge\bfseries\titlerule\vspace{0.25cm}}{\LARGE\chaptertitlename~\thechapter}{1em}{}[\vspace{0.25cm}\titlerule]
\titleformat{\section}{\myheadingfont\Large\bfseries}{\thesection}{1em}{}
\titleformat{\subsection}{\myheadingfont\large\bfseries}{\thesubsection}{1em}{}
\titleformat{\subsubsection}{\myheadingfont\normalsize\bfseries}{\thesubsubsection}{1em}{}
\titleformat{\paragraph}{\myheadingfont\normalsize\bfseries}{\theparagraph}{1em}{}
\titleformat{\subparagraph}{\myheadingfont\normalsize}{\thesubparagraph}{1em}{\labelitemi~}
\titlespacing*{\chapter}{0pt}{50pt}{40pt minus \parskip}
\titlespacing*{\section}{0pt}{3.5ex plus 1ex minus .2ex - \parskip}{2.3ex plus .2ex - \parskip}
\titlespacing*{\subsection}{0pt}{3.25ex plus 1ex minus .2ex - \parskip}{1.5ex plus .2ex - \parskip}
\titlespacing*{\subsubsection}{0pt}{3.25ex plus 1ex minus .2ex - \parskip}{1.5ex plus .2ex - \parskip} 
\titlespacing*{\paragraph}{0pt}{3.25ex plus 1ex minus .2ex - \parskip}{1.5ex plus .2ex - \parskip} 
\titlespacing*{\subparagraph}{0pt}{3.25ex plus 1ex minus .2ex - \parskip}{1.5ex plus .2ex - \parskip} 
\ifthenelse{\boolean{earlydraft}}{
    \setcounter{tocdepth}{3}
    \setcounter{secnumdepth}{3}
}{
    \setcounter{tocdepth}{3}
    \setcounter{secnumdepth}{3}
}
% -----------------------------------------------------------------------------


% -----------------------------------------------------------------------------
% Commands for setting author, title, ...
% -----------------------------------------------------------------------------
\renewcommand{\author}[1]{\gdef\theauthor{#1}}
\renewcommand{\title}[1]{\gdef\thetitle{#1}}
\newcommand{\thesistype}[1]{\gdef\thethesistype{#1}}
\newcommand{\thesiscite}[1]{\gdef\thethesiscite{#1}}
\newcommand{\birthday}[1]{\gdef\thebirthday{#1}}
\newcommand{\birthplace}[1]{\gdef\thebirthplace{#1}}
\newcommand{\advisors}[1]{\gdef\theadvisors{#1}}
\newcommand{\referees}[1]{\gdef\thereferees{#1}}
% -----------------------------------------------------------------------------


% -----------------------------------------------------------------------------
% Listings
% -----------------------------------------------------------------------------
\RequirePackage[savemem]{listings}
\ifthenelse{\boolean{germanthesis}}{
    \renewcommand{\lstlistlistingname}{Listingverzeichnis}
}{
    \renewcommand{\lstlistlistingname}{List of Listings}
}
\lstset{
    language=C,
    frame=lines,
    framesep=5pt,
    captionpos=b,
    abovecaptionskip=1em,
    numbers=left,
    xleftmargin=15pt,
    framexleftmargin=15pt,
    numberstyle=\tiny,
    numbersep=5pt,
    stepnumber=1,
    fontadjust,
    tabsize=2,
    showtabs=false,
    showspaces=false,
    showstringspaces=false,
    breaklines=true,
    breakatwhitespace=true,
    keywordstyle=\color{black},
    identifierstyle=\bfseries\color{blue},
    commentstyle=\color{red},
    prebreak=\raisebox{0ex}[0ex][0ex]{\color{gray}\ensuremath{\searrow}},
    stringstyle=\bfseries\color{blue},
    basicstyle=\ttfamily\bfseries\color{black}\footnotesize,
}
\lstdefinestyle{txt}{
    float,
    floatplacement=bp,
    language=C
}
\lstdefinestyle{xml}{
    float,
    floatplacement=bp,
    language=XML
}
% -----------------------------------------------------------------------------


% -----------------------------------------------------------------------------
% TOCs
% -----------------------------------------------------------------------------

% Include list-of-Xs in table of contents
\ifthenelse{\boolean{earlydraft}}{
    \RequirePackage[]{tocbibind}
    \renewcommand{\lstlistoflistings}{\begingroup\tocfile{\lstlistlistingname}{lol}\endgroup}
    \newcommand{\listofabbreviations}{\addcontentsline{toc}{chapter}{\glossarytitlename}\printacronyms}
    \newcommand{\mymaketodotocentry}{\todototoc}
}{
    \RequirePackage[nottoc,notlot,notlof]{tocbibind}
    \newcommand{\listofabbreviations}{\printacronyms}
    \newcommand{\mymaketodotocentry}{}
}

% -----------------------------------------------------------------------------


% -----------------------------------------------------------------------------
% Visible TODO and FIXME markers
% -----------------------------------------------------------------------------
\ifthenelse{\boolean{germanthesis}}{
    \@ifpackagelater{siunitx}{2021/06/04}{
        \RequirePackage[loadshadowlibrary,colorinlistoftodos, textwidth=3.75cm, shadow, ngerman]{todonotes}
    }{
        \RequirePackage[colorinlistoftodos, textwidth=3.75cm, shadow, ngerman]{todonotes}
    }
    \@todonotes@SetTodoListName{Offene Punkte}
}{
    \@ifpackagelater{siunitx}{2021/06/04}{
        \RequirePackage[loadshadowlibrary,colorinlistoftodos, textwidth=3.75cm, shadow]{todonotes}
    }{
        \RequirePackage[colorinlistoftodos, textwidth=3.75cm, shadow]{todonotes}
    }
}
\newcounter{TODOCOUNT}
\newcommand{\TODO}[1]{\vspace{0.5em}\todo[inline, color=orange]{#1}\stepcounter{TODOCOUNT}}
\newcommand{\FIXME}[1]{\todo[size=\small, color=red]{#1}\stepcounter{TODOCOUNT}}
\AtEndDocument{
    \ifnum\value{TODOCOUNT}>0
        %\cleardoublepage
        \mymaketodotocentry\listoftodos
    \fi
}
% -----------------------------------------------------------------------------


% -----------------------------------------------------------------------------
% Title page
% -----------------------------------------------------------------------------
\newcommand{\coverpagetextsmall}[1]{%
    \@nsmgroupcoverpage@smalltextsize%
    #1%
    \vspace{0.5cm}\\%
}

\newcommand{\coverpagetextlarge}[1]{%
    \vspace{0.25cm}%
    \@nsmgroupcoverpage@largetextsize%
    #1%
    \@nsmgroupcoverpage@smalltextsize%
    \vspace{0.5cm}\\%
}
\renewcommand{\maketitle}{%

% Do some stuff we had to postpone until after e.g. \thetitle was set
\hypersetup{%
  pdftitle = {\thetitle},
  pdfsubject = {\thethesistype},
  pdfauthor = {\theauthor},
  pdfborder=0 0 0
}

% Count authors
\newcounter{@nsmauthorcount}%
\foreach \n [count=\ni] in \theauthor {%
    \stepcounter{@nsmauthorcount}%
}%

\pagenumbering{alph}

% Output cover page
\ifthenelse{\boolean{cutmargins}}{
    % no cover page if cutmargins is set
}
{%

\tikzoption{text @nsmgroupcoverpage@ badly raggedleft}[]{\def\tikz@text@action{\raggedleft\relax}}

\begingroup
\pagestyle{empty}
\setcounter{page}\@ne

\def\@nsmgroupcoverpage@titlesize{\@setfontsize{\@nsmgroupcoverpage@titlesize}{20}{24pt}}
\def\@nsmgroupcoverpage@subtitlesize{\@setfontsize{\@nsmgroupcoverpage@subtitlesize}{14}{17pt}}
\def\@nsmgroupcoverpage@citeassize{\@setfontsize{\@nsmgroupcoverpage@citeassize}{8}{9pt}}
\def\@nsmgroupcoverpage@addressize{\@setfontsize{\@nsmgroupcoverpage@addressize}{8}{9pt}}
\def\@nsmgroupcoverpage@smalltextsize{\@setfontsize{\@nsmgroupcoverpage@smalltextsize}{14}{17pt}}
\def\@nsmgroupcoverpage@largetextsize{\@setfontsize{\@nsmgroupcoverpage@largetextsize}{20}{24pt}}

\renewcommand{\baselinestretch}{1.00}

\begin{tikzpicture}[remember picture,overlay] \node[xshift=0cm,yshift=0cm] at (current page.south west) { \begin{tikzpicture}[remember picture, overlay]

    \definecolor{tudblue}{HTML}{00305d}

    \draw[xshift=2cm,yshift=2.50cm] node [anchor=west] {%
        \begin{tikzpicture}[y=5pt, x=5pt, yscale=-1, xscale=1, inner sep=0pt, outer sep=0pt]
            \path[fill=tudblue,line width=0.212pt] (25.0891,15.9343) -- (25.0891,18.3969) -- (24.5027,18.3969) -- (24.5027,15.9343) -- (23.7288,15.9343) -- (23.7288,15.4183) -- (25.8748,15.4183) -- (25.8748,15.9343) -- cycle(26.3908,18.3969) -- (26.3908,15.4183) -- (28.3609,15.4183) -- (28.3609,15.9343) -- (26.9771,15.9343) -- (26.9771,16.6379) -- (28.1498,16.6379) -- (28.1498,17.1539) -- (26.9771,17.1539) -- (26.9771,17.8809) -- (28.3609,17.8809) -- (28.3609,18.3969) -- cycle(30.7063,18.1741) .. controls (30.5069,18.3383) and (30.2606,18.4204) .. (29.9792,18.4204) .. controls (29.6626,18.4204) and (29.3929,18.3148) .. (29.1700,18.0920) .. controls (29.0410,17.9630) and (28.9590,17.8106) .. (28.9238,17.6464) .. controls (28.8886,17.4822) and (28.8769,17.2360) .. (28.8769,16.9076) .. controls (28.8769,16.5793) and (28.8886,16.3330) .. (28.9238,16.1688) .. controls (28.9590,16.0046) and (29.0410,15.8522) .. (29.1700,15.7232) .. controls (29.3929,15.5004) and (29.6508,15.3948) .. (29.9792,15.3948) .. controls (30.2724,15.3948) and (30.5069,15.4769) .. (30.7063,15.6411) .. controls (30.9056,15.8053) and (31.0229,16.0398) .. (31.0815,16.3447) -- (30.4952,16.3447) .. controls (30.4600,16.2157) and (30.4131,16.1102) .. (30.3310,16.0398) .. controls (30.2489,15.9577) and (30.1434,15.9226) .. (30.0027,15.9226) .. controls (29.8385,15.9226) and (29.7212,15.9695) .. (29.6274,16.0750) .. controls (29.5922,16.1102) and (29.5688,16.1454) .. (29.5570,16.1805) .. controls (29.5336,16.2157) and (29.5219,16.2744) .. (29.5101,16.3330) .. controls (29.4984,16.3916) and (29.4984,16.4620) .. (29.4867,16.5558) .. controls (29.4867,16.6496) and (29.4749,16.7669) .. (29.4749,16.9193) .. controls (29.4749,17.0718) and (29.4749,17.1891) .. (29.4867,17.2829) .. controls (29.4867,17.3767) and (29.4984,17.4471) .. (29.5101,17.5057) .. controls (29.5219,17.5643) and (29.5336,17.6112) .. (29.5570,17.6581) .. controls (29.5805,17.6933) and (29.6039,17.7285) .. (29.6274,17.7637) .. controls (29.7212,17.8692) and (29.8385,17.9161) .. (30.0027,17.9161) .. controls (30.1434,17.9161) and (30.2489,17.8809) .. (30.3310,17.7989) .. controls (30.4131,17.7168) and (30.4717,17.6230) .. (30.4952,17.4940) -- (31.0815,17.4940) .. controls (31.0229,17.7871) and (30.8939,18.0217) .. (30.7063,18.1741) -- cycle(33.2158,18.3969) -- (33.2158,17.1539) -- (32.2073,17.1539) -- (32.2073,18.3969) -- (31.6210,18.3969) -- (31.6210,15.4183) -- (32.2073,15.4183) -- (32.2073,16.6379) -- (33.2158,16.6379) -- (33.2158,15.4183) -- (33.8022,15.4183) -- (33.8022,18.3969) -- cycle(36.3117,18.3969) -- (35.1273,16.5675) -- (35.1273,18.3969) -- (34.5410,18.3969) -- (34.5410,15.4183) -- (35.0569,15.4183) -- (36.2414,17.2477) -- (36.2414,15.4183) -- (36.8277,15.4183) -- (36.8277,18.3969) -- cycle(37.5782,18.3969) -- (37.5782,15.4183) -- (38.1646,15.4183) -- (38.1646,18.3969) -- cycle(40.5217,18.1858) .. controls (40.3106,18.3500) and (40.0526,18.4321) .. (39.7242,18.4321) .. controls (39.4897,18.4321) and (39.2903,18.3969) .. (39.1144,18.3383) .. controls (38.9385,18.2797) and (38.7861,18.1741) .. (38.6336,18.0334) -- (39.0089,17.6581) .. controls (39.1027,17.7519) and (39.2083,17.8106) .. (39.3255,17.8458) .. controls (39.4428,17.8809) and (39.5835,17.9044) .. (39.7242,17.9044) .. controls (40.0760,17.9044) and (40.2519,17.7871) .. (40.2519,17.5409) .. controls (40.2519,17.4353) and (40.2285,17.3532) .. (40.1699,17.2946) .. controls (40.1112,17.2360) and (40.0291,17.2008) .. (39.8884,17.1773) -- (39.7242,17.1539) -- (39.5366,17.1304) .. controls (39.2786,17.0952) and (39.0910,17.0132) .. (38.9620,16.8842) .. controls (38.8213,16.7434) and (38.7509,16.5441) .. (38.7509,16.2978) .. controls (38.7509,16.0281) and (38.8447,15.8053) .. (39.0324,15.6411) .. controls (39.2200,15.4769) and (39.4780,15.3948) .. (39.7946,15.3948) .. controls (40.0057,15.3948) and (40.1816,15.4183) .. (40.3340,15.4769) .. controls (40.4865,15.5356) and (40.6272,15.6177) .. (40.7562,15.7467) -- (40.3927,16.1102) .. controls (40.3106,16.0281) and (40.2168,15.9695) .. (40.1112,15.9460) .. controls (40.0057,15.9226) and (39.9001,15.8991) .. (39.7829,15.8991) .. controls (39.6304,15.8991) and (39.5249,15.9343) .. (39.4428,16.0046) .. controls (39.3607,16.0750) and (39.3255,16.1688) .. (39.3255,16.2744) .. controls (39.3255,16.3565) and (39.3607,16.4268) .. (39.4193,16.4854) .. controls (39.4780,16.5441) and (39.5718,16.5910) .. (39.6891,16.6027) -- (39.8650,16.6262) -- (40.0409,16.6496) .. controls (40.1699,16.6731) and (40.2871,16.6965) .. (40.3809,16.7317) .. controls (40.4747,16.7669) and (40.5451,16.8138) .. (40.6155,16.8842) .. controls (40.7679,17.0249) and (40.8500,17.2360) .. (40.8500,17.5174) .. controls (40.8266,17.7989) and (40.7327,18.0217) .. (40.5217,18.1858) -- cycle(43.1485,18.1741) .. controls (42.9491,18.3383) and (42.7029,18.4204) .. (42.4214,18.4204) .. controls (42.1048,18.4204) and (41.8351,18.3148) .. (41.6123,18.0920) .. controls (41.4833,17.9630) and (41.4012,17.8106) .. (41.3660,17.6464) .. controls (41.3308,17.4822) and (41.3191,17.2360) .. (41.3191,16.9076) .. controls (41.3191,16.5793) and (41.3308,16.3330) .. (41.3660,16.1688) .. controls (41.4012,16.0046) and (41.4833,15.8522) .. (41.6123,15.7232) .. controls (41.8351,15.5004) and (42.0931,15.3948) .. (42.4214,15.3948) .. controls (42.7146,15.3948) and (42.9491,15.4769) .. (43.1485,15.6411) .. controls (43.3478,15.8053) and (43.4651,16.0398) .. (43.5237,16.3447) -- (42.9374,16.3447) .. controls (42.9022,16.2157) and (42.8553,16.1102) .. (42.7732,16.0398) .. controls (42.6911,15.9577) and (42.5856,15.9226) .. (42.4449,15.9226) .. controls (42.2807,15.9226) and (42.1634,15.9695) .. (42.0696,16.0750) .. controls (42.0344,16.1102) and (42.0110,16.1454) .. (41.9993,16.1805) .. controls (41.9758,16.2157) and (41.9641,16.2744) .. (41.9523,16.3330) .. controls (41.9406,16.3916) and (41.9406,16.4620) .. (41.9289,16.5558) .. controls (41.9289,16.6496) and (41.9172,16.7669) .. (41.9172,16.9193) .. controls (41.9172,17.0718) and (41.9172,17.1891) .. (41.9289,17.2829) .. controls (41.9289,17.3767) and (41.9406,17.4470) .. (41.9523,17.5057) .. controls (41.9641,17.5643) and (41.9758,17.6112) .. (41.9993,17.6581) .. controls (42.0227,17.6933) and (42.0462,17.7285) .. (42.0696,17.7637) .. controls (42.1634,17.8692) and (42.2807,17.9161) .. (42.4449,17.9161) .. controls (42.5856,17.9161) and (42.6911,17.8809) .. (42.7732,17.7989) .. controls (42.8553,17.7168) and (42.9139,17.6230) .. (42.9374,17.4940) -- (43.5237,17.4940) .. controls (43.4768,17.7871) and (43.3478,18.0217) .. (43.1485,18.1741) -- cycle(45.6698,18.3969) -- (45.6698,17.1539) -- (44.6613,17.1539) -- (44.6613,18.3969) -- (44.0749,18.3969) -- (44.0749,15.4183) -- (44.6613,15.4183) -- (44.6613,16.6379) -- (45.6698,16.6379) -- (45.6698,15.4183) -- (46.2561,15.4183) -- (46.2561,18.3969) -- cycle(46.9949,18.3969) -- (46.9949,15.4183) -- (48.9650,15.4183) -- (48.9650,15.9343) -- (47.5812,15.9343) -- (47.5812,16.6379) -- (48.7539,16.6379) -- (48.7539,17.1539) -- (47.5812,17.1539) -- (47.5812,17.8809) -- (48.9650,17.8809) -- (48.9650,18.3969) -- cycle(25.8396,21.7860) .. controls (25.7810,21.9150) and (25.7106,22.0205) .. (25.6051,22.1143) .. controls (25.4995,22.2082) and (25.3823,22.2785) .. (25.2533,22.3254) .. controls (25.1243,22.3723) and (24.9718,22.3958) .. (24.8311,22.3958) .. controls (24.6786,22.3958) and (24.5379,22.3723) .. (24.4089,22.3254) .. controls (24.2799,22.2785) and (24.1627,22.2082) .. (24.0571,22.1143) .. controls (23.9516,22.0205) and (23.8812,21.9150) .. (23.8226,21.7860) .. controls (23.7640,21.6570) and (23.7405,21.5163) .. (23.7405,21.3638) -- (23.7405,19.3937) -- (24.3268,19.3937) -- (24.3268,21.3286) .. controls (24.3268,21.5045) and (24.3738,21.6335) .. (24.4676,21.7274) .. controls (24.5614,21.8212) and (24.6904,21.8798) .. (24.8428,21.8798) .. controls (25.0070,21.8798) and (25.1243,21.8329) .. (25.2181,21.7274) .. controls (25.3119,21.6218) and (25.3588,21.4928) .. (25.3588,21.3286) -- (25.3588,19.3937) -- (25.9334,19.3937) -- (25.9334,21.3521) .. controls (25.9217,21.5163) and (25.8982,21.6570) .. (25.8396,21.7860) -- cycle(28.3492,22.3841) -- (27.1647,20.5547) -- (27.1647,22.3841) -- (26.5784,22.3841) -- (26.5784,19.3937) -- (27.0944,19.3937) -- (28.2788,21.2231) -- (28.2788,19.3937) -- (28.8651,19.3937) -- (28.8651,22.3723) -- (28.3492,22.3723) -- cycle(29.5805,22.3841) -- (29.5805,19.3937) -- (30.1668,19.3937) -- (30.1668,22.3723) -- (29.5805,22.3723) -- cycle(31.9610,22.3841) -- (31.5271,22.3841) -- (30.5421,19.4054) -- (31.1402,19.4054) -- (31.7382,21.3521) -- (32.3363,19.4054) -- (32.9461,19.4054) -- cycle(33.3331,22.3841) -- (33.3331,19.3937) -- (35.3032,19.3937) -- (35.3032,19.9097) -- (33.9194,19.9097) -- (33.9194,20.6133) -- (35.0921,20.6133) -- (35.0921,21.1293) -- (33.9194,21.1293) -- (33.9194,21.8564) -- (35.3032,21.8564) -- (35.3032,22.3723) -- (33.3331,22.3723) -- cycle(37.4609,22.3841) -- (36.8746,21.1996) -- (36.4524,21.1996) -- (36.4524,22.3841) -- (35.8661,22.3841) -- (35.8661,19.3937) -- (37.0388,19.3937) .. controls (37.1912,19.3937) and (37.3202,19.4172) .. (37.4375,19.4641) .. controls (37.5548,19.5110) and (37.6603,19.5813) .. (37.7424,19.6634) .. controls (37.8245,19.7455) and (37.8948,19.8393) .. (37.9300,19.9566) .. controls (37.9769,20.0621) and (38.0004,20.1794) .. (38.0004,20.3084) .. controls (38.0004,20.5078) and (37.9535,20.6719) .. (37.8479,20.8127) .. controls (37.7424,20.9417) and (37.6134,21.0472) .. (37.4609,21.0941) -- (38.1294,22.3841) -- cycle(37.3202,20.0270) .. controls (37.2381,19.9566) and (37.1443,19.9214) .. (37.0153,19.9214) -- (36.4642,19.9214) -- (36.4642,20.7071) -- (37.0153,20.7071) .. controls (37.1443,20.7071) and (37.2381,20.6719) .. (37.3202,20.6016) .. controls (37.4023,20.5312) and (37.4375,20.4374) .. (37.4375,20.3201) .. controls (37.4375,20.1911) and (37.3906,20.0973) .. (37.3202,20.0270) -- cycle(40.2519,22.1613) .. controls (40.0409,22.3254) and (39.7829,22.4075) .. (39.4545,22.4075) .. controls (39.2200,22.4075) and (39.0206,22.3723) .. (38.8447,22.3137) .. controls (38.6688,22.2551) and (38.5164,22.1495) .. (38.3639,22.0088) -- (38.7392,21.6335) .. controls (38.8330,21.7274) and (38.9385,21.7860) .. (39.0558,21.8212) .. controls (39.1731,21.8564) and (39.3138,21.8798) .. (39.4545,21.8798) .. controls (39.8063,21.8798) and (39.9822,21.7625) .. (39.9822,21.5163) .. controls (39.9822,21.4107) and (39.9588,21.3286) .. (39.9001,21.2700) .. controls (39.8415,21.2114) and (39.7594,21.1762) .. (39.6187,21.1527) -- (39.4545,21.1293) -- (39.2669,21.1058) .. controls (39.0089,21.0707) and (38.8213,20.9886) .. (38.6923,20.8596) .. controls (38.5515,20.7188) and (38.4812,20.5195) .. (38.4812,20.2732) .. controls (38.4812,20.0035) and (38.5750,19.7807) .. (38.7626,19.6165) .. controls (38.9503,19.4523) and (39.2083,19.3703) .. (39.5249,19.3703) .. controls (39.7360,19.3703) and (39.9119,19.3937) .. (40.0643,19.4523) .. controls (40.2168,19.5110) and (40.3575,19.5931) .. (40.4865,19.7221) -- (40.1230,20.0856) .. controls (40.0409,20.0035) and (39.9470,19.9449) .. (39.8415,19.9214) .. controls (39.7360,19.8980) and (39.6304,19.8745) .. (39.5132,19.8745) .. controls (39.3607,19.8745) and (39.2552,19.9097) .. (39.1731,19.9801) .. controls (39.0910,20.0504) and (39.0558,20.1442) .. (39.0558,20.2498) .. controls (39.0558,20.3319) and (39.0910,20.4022) .. (39.1496,20.4609) .. controls (39.2083,20.5195) and (39.3021,20.5664) .. (39.4193,20.5781) -- (39.5952,20.6016) -- (39.7711,20.6250) .. controls (39.9001,20.6485) and (40.0174,20.6719) .. (40.1112,20.7071) .. controls (40.2050,20.7423) and (40.2754,20.7892) .. (40.3458,20.8596) .. controls (40.4982,21.0003) and (40.5803,21.2114) .. (40.5803,21.4928) .. controls (40.5686,21.7860) and (40.4630,21.9971) .. (40.2520,22.1612) -- cycle(41.1315,22.3841) -- (41.1315,19.3937) -- (41.7178,19.3937) -- (41.7178,22.3723) -- (41.1315,22.3723) -- cycle(43.5589,19.9214) -- (43.5589,22.3841) -- (42.9726,22.3841) -- (42.9726,19.9214) -- (42.1986,19.9214) -- (42.1986,19.4054) -- (44.3446,19.4054) -- (44.3446,19.9214) -- cycle(46.2796,22.3841) -- (46.1037,21.8564) -- (45.0482,21.8564) -- (44.8723,22.3841) -- (44.2625,22.3841) -- (45.3531,19.4054) -- (45.8105,19.4054) -- (46.9011,22.3841) -- cycle(45.5877,20.2732) -- (45.2124,21.3638) -- (45.9512,21.3638) -- cycle(44.6378,18.8543) -- (45.1538,18.8543) -- (45.1538,19.3820) -- (44.6378,19.3820) -- cycle(46.0333,18.8543) -- (46.0333,19.3820) -- (46.5493,19.3820) -- (46.5493,18.8543) -- cycle(48.1559,19.9214) -- (48.1559,22.3841) -- (47.5695,22.3841) -- (47.5695,19.9214) -- (46.7955,19.9214) -- (46.7955,19.4054) -- (48.9416,19.4054) -- (48.9416,19.9214) -- cycle(25.8396,25.6207) .. controls (25.8044,25.7966) and (25.7223,25.9490) .. (25.5933,26.0780) .. controls (25.4995,26.1718) and (25.3823,26.2422) .. (25.2533,26.2891) .. controls (25.1125,26.3360) and (24.9718,26.3595) .. (24.8076,26.3595) -- (23.7288,26.3595) -- (23.7288,23.3808) -- (24.8076,23.3808) .. controls (24.9718,23.3808) and (25.1125,23.4043) .. (25.2533,23.4512) .. controls (25.3940,23.4981) and (25.4995,23.5685) .. (25.5933,23.6623) .. controls (25.6637,23.7327) and (25.7223,23.8030) .. (25.7575,23.8851) .. controls (25.7927,23.9672) and (25.8279,24.0493) .. (25.8513,24.1431) .. controls (25.8748,24.2369) and (25.8865,24.3425) .. (25.8865,24.4480) .. controls (25.8865,24.5535) and (25.8982,24.6943) .. (25.8982,24.8702) .. controls (25.8982,25.1868) and (25.8748,25.4448) .. (25.8396,25.6207) -- cycle(25.2884,24.3425) .. controls (25.2767,24.2369) and (25.2415,24.1548) .. (25.1829,24.0845) .. controls (25.0774,23.9672) and (24.9366,23.8968) .. (24.7490,23.8968) -- (24.3034,23.8968) -- (24.3034,25.8435) -- (24.7490,25.8435) .. controls (24.9366,25.8435) and (25.0891,25.7849) .. (25.1829,25.6559) .. controls (25.2415,25.5972) and (25.2650,25.5034) .. (25.2884,25.3861) .. controls (25.3002,25.2689) and (25.3119,25.0930) .. (25.3119,24.8467) .. controls (25.3119,24.6239) and (25.3002,24.4480) .. (25.2884,24.3425) -- cycle(28.0912,26.3595) -- (27.5048,25.1751) -- (27.0944,25.1751) -- (27.0944,26.3595) -- (26.5080,26.3595) -- (26.5080,23.3808) -- (27.6807,23.3808) .. controls (27.8332,23.3808) and (27.9622,23.4043) .. (28.0794,23.4512) .. controls (28.1967,23.4981) and (28.3023,23.5685) .. (28.3843,23.6506) .. controls (28.4664,23.7327) and (28.5368,23.8265) .. (28.5720,23.9437) .. controls (28.6189,24.0493) and (28.6423,24.1665) .. (28.6423,24.2955) .. controls (28.6423,24.4949) and (28.5954,24.6591) .. (28.4899,24.7998) .. controls (28.3843,24.9288) and (28.2553,25.0343) .. (28.1029,25.0812) -- (28.7713,26.3712) -- (28.0912,26.3712) -- cycle(27.9387,24.0024) .. controls (27.8566,23.9320) and (27.7628,23.8968) .. (27.6338,23.8968) -- (27.0944,23.8968) -- (27.0944,24.6825) -- (27.6456,24.6825) .. controls (27.7745,24.6825) and (27.8684,24.6474) .. (27.9504,24.5770) .. controls (28.0325,24.5066) and (28.0677,24.4128) .. (28.0677,24.2955) .. controls (28.0560,24.1783) and (28.0208,24.0727) .. (27.9387,24.0024) -- cycle(29.2639,26.3595) -- (29.2639,23.3808) -- (31.2340,23.3808) -- (31.2340,23.8968) -- (29.8502,23.8968) -- (29.8502,24.6004) -- (31.0229,24.6004) -- (31.0229,25.1164) -- (29.8502,25.1164) -- (29.8502,25.8435) -- (31.2340,25.8435) -- (31.2340,26.3595) -- cycle(33.4269,26.1484) .. controls (33.2158,26.3126) and (32.9578,26.3947) .. (32.6295,26.3947) .. controls (32.3949,26.3947) and (32.1956,26.3595) .. (32.0197,26.3008) .. controls (31.8438,26.2422) and (31.6913,26.1367) .. (31.5389,25.9959) -- (31.9141,25.6207) .. controls (32.0079,25.7145) and (32.1135,25.7731) .. (32.2308,25.8083) .. controls (32.3480,25.8435) and (32.4888,25.8669) .. (32.6295,25.8669) .. controls (32.9813,25.8669) and (33.1572,25.7497) .. (33.1572,25.5034) .. controls (33.1572,25.3979) and (33.1337,25.3158) .. (33.0751,25.2572) .. controls (33.0165,25.1985) and (32.9344,25.1633) .. (32.7936,25.1399) -- (32.6295,25.1164) -- (32.4418,25.0930) .. controls (32.1839,25.0578) and (31.9962,24.9757) .. (31.8672,24.8467) .. controls (31.7265,24.7060) and (31.6561,24.5066) .. (31.6561,24.2604) .. controls (31.6561,23.9907) and (31.7500,23.7678) .. (31.9376,23.6037) .. controls (32.1252,23.4395) and (32.3832,23.3574) .. (32.6998,23.3574) .. controls (32.9109,23.3574) and (33.0868,23.3809) .. (33.2393,23.4395) .. controls (33.3917,23.4981) and (33.5324,23.5802) .. (33.6614,23.7092) -- (33.2979,24.0727) .. controls (33.2158,23.9907) and (33.1220,23.9320) .. (33.0165,23.9086) .. controls (32.9109,23.8851) and (32.8054,23.8617) .. (32.6881,23.8617) .. controls (32.5357,23.8617) and (32.4301,23.8968) .. (32.3480,23.9672) .. controls (32.2659,24.0376) and (32.2308,24.1314) .. (32.2308,24.2369) .. controls (32.2308,24.3190) and (32.2659,24.3894) .. (32.3246,24.4480) .. controls (32.3832,24.5066) and (32.4770,24.5535) .. (32.5943,24.5653) -- (32.7702,24.5887) -- (32.9461,24.6122) .. controls (33.0751,24.6356) and (33.1924,24.6591) .. (33.2862,24.6943) .. controls (33.3800,24.7294) and (33.4504,24.7764) .. (33.5207,24.8467) .. controls (33.6732,24.9874) and (33.7553,25.1985) .. (33.7553,25.4800) .. controls (33.7435,25.7614) and (33.6380,25.9842) .. (33.4269,26.1484) -- cycle(36.4173,25.6207) .. controls (36.3821,25.7966) and (36.3000,25.9490) .. (36.1710,26.0780) .. controls (36.0772,26.1718) and (35.9599,26.2422) .. (35.8309,26.2891) .. controls (35.6902,26.3360) and (35.5495,26.3595) .. (35.3853,26.3595) -- (34.3064,26.3595) -- (34.3064,23.3808) -- (35.3853,23.3808) .. controls (35.5495,23.3808) and (35.6902,23.4043) .. (35.8309,23.4512) .. controls (35.9716,23.4981) and (36.0772,23.5685) .. (36.1710,23.6623) .. controls (36.2414,23.7327) and (36.3000,23.8030) .. (36.3352,23.8851) .. controls (36.3703,23.9672) and (36.4055,24.0493) .. (36.4290,24.1431) .. controls (36.4524,24.2369) and (36.4642,24.3425) .. (36.4642,24.4480) .. controls (36.4642,24.5535) and (36.4759,24.6943) .. (36.4759,24.8702) .. controls (36.4759,25.1868) and (36.4524,25.4448) .. (36.4173,25.6207) -- cycle(35.8661,24.3425) .. controls (35.8544,24.2369) and (35.8192,24.1548) .. (35.7606,24.0845) .. controls (35.6550,23.9672) and (35.5143,23.8968) .. (35.3267,23.8968) -- (34.8810,23.8968) -- (34.8810,25.8435) -- (35.3267,25.8435) .. controls (35.5143,25.8435) and (35.6667,25.7849) .. (35.7606,25.6559) .. controls (35.8192,25.5972) and (35.8426,25.5034) .. (35.8661,25.3861) .. controls (35.8778,25.2689) and (35.8895,25.0930) .. (35.8895,24.8467) .. controls (35.8895,24.6239) and (35.8778,24.4480) .. (35.8661,24.3425) -- cycle(37.0857,26.3595) -- (37.0857,23.3808) -- (39.0558,23.3808) -- (39.0558,23.8968) -- (37.6720,23.8968) -- (37.6720,24.6004) -- (38.8447,24.6004) -- (38.8447,25.1164) -- (37.6720,25.1164) -- (37.6720,25.8435) -- (39.0558,25.8435) -- (39.0558,26.3595) -- cycle(41.4012,26.3595) -- (40.2168,24.5301) -- (40.2168,26.3595) -- (39.6304,26.3595) -- (39.6304,23.3808) -- (40.1464,23.3808) -- (41.3308,25.2102) -- (41.3308,23.3808) -- (41.9172,23.3808) -- (41.9172,26.3595) -- cycle(18.6979,26.3478) -- (22.0049,23.0290) -- (22.0049,18.7370) -- (18.6979,15.4183) -- (14.3824,15.4183) -- (11.0637,18.7370) -- (11.0637,18.7370) -- (11.0637,18.7370) -- (11.0637,23.0408) -- (14.3824,26.3595) -- (18.6979,26.3595) -- cycle(14.5114,26.0194) -- (11.3921,22.9001) -- (11.3921,18.8660) -- (11.3921,18.8660) -- (14.5114,15.7467) -- (18.5572,15.7467) -- (21.6648,18.8543) -- (21.6648,22.9001) -- (18.5572,26.0077) -- (14.5114,26.0077) -- cycle(15.3792,22.5365) -- (15.3792,19.0654) -- (12.1309,19.0654) -- (14.7812,16.4151) -- (18.2992,16.4151) -- (20.9495,19.0654) -- (20.9495,19.0654) -- (20.9495,19.0654) -- (17.7012,19.0654) -- (17.7012,22.5365) -- cycle(18.0295,22.8766) -- (18.0295,19.3937) -- (21.3365,19.3937) -- (21.3365,19.3937) -- (21.3365,19.3937) -- (21.3365,19.3937) -- (21.3365,18.9833) -- (18.4282,16.0867) -- (14.6404,16.0867) -- (11.7322,18.9950) -- (11.7322,19.4054) -- (15.0509,19.4054) -- (15.0509,22.8766) -- cycle(18.2992,25.3510) -- (21.0081,22.6421) -- (21.0199,20.0504) -- (21.0199,20.0504) -- (21.0199,20.0504) -- (18.6979,20.0504) -- (18.6979,23.5216) -- (14.3824,23.5216) -- (14.3824,20.0621) -- (12.0605,20.0621) -- (12.0605,22.6538) -- (14.7812,25.3510) -- cycle(14.6404,25.6910) -- (11.7322,22.7828) -- (11.7322,19.7338) -- (11.7322,19.7338) -- (11.7322,19.7338) -- (14.7108,19.7338) -- (14.7108,23.2050) -- (18.3579,23.2050) -- (18.3579,19.7338) -- (21.3365,19.7338) -- (21.3365,22.7828) -- (18.4282,25.6910) -- cycle;
        \end{tikzpicture}
    };

    \draw[tudblue, ultra thick] (1,24.658) -- (20,24.658);
    \draw[tudblue, ultra thick] (1,5.042) -- (20,5.042);

    %%% multi-line text
    \pgftext[top,left,at={\pgfpoint{2.5cm}{20cm}}] {%
        \parbox{15cm}{%
            \raggedright%
            \sffamily%
            \@nsmgroupcoverpage@largetextsize%
            \renewcommand{\baselinestretch}{1.25}%
            \coverpagetextsmall{\nohyphens{%
                \foreach \n [count=\ni] in \theauthor {%
                    \ifnum\ni=1%
                    \else
                        \ifnum\ni=\the@nsmauthorcount%
                            ~und~%
                        \else%
                            ,~%
                        \fi%
                    \fi%
                    \n
                }%
            }}%
            \coverpagetextlarge{\nohyphens{\thetitle}}%
            \coverpagetextsmall{\thethesistype}%
            \coverpagetextsmall{\americandateformat\today}%
        }%
    };
    \draw[xshift=2.5cm,yshift=6cm] node [above right,text width=15cm, text badly ragged] {%
        \sffamily%
        \@nsmgroupcoverpage@citeassize%
        \renewcommand{\baselinestretch}{1.00}%
        \begin{otherlanguage*}{american}%
            Please cite as:\\%
            \nohyphens{%
                \foreach \n [count=\ni] in \theauthor {%
                    \ifnum\ni=1%
                    \else
                        \ifnum\ni=\the@nsmauthorcount%
                            ~and~%
                        \else%
                            ,~%
                        \fi%
                    \fi%
                    \n
                }%
            , ``\thetitle,'' \thethesiscite, Faculty of Computer Science, TU Dresden, Germany, \monthname~\the\year.}%
        \end{otherlanguage*}
    };
    \draw[xshift=19.08cm,yshift=2.50cm] node [left,text width=12cm, text @nsmgroupcoverpage@ badly raggedleft] {%
        \sffamily%
        \@nsmgroupcoverpage@addressize%
        \renewcommand{\baselinestretch}{1.00}%
        Networked Systems Modeling\\%
        Faculty of Computer Science, TU Dresden\\[1\baselineskip]%
        Nöthnitzer Str. 46 $\cdot$ 01187 Dresden $\cdot$ Germany\\[1\baselineskip]%
        \href{https://nsm.inf.tu-dresden.de/}{https://nsm.inf.tu-dresden.de/}%
    };
\end{tikzpicture} }; \end{tikzpicture}

\cleardoublepage
\setcounter{page}\@ne
\endgroup
}

% Title pages use single line spacing, no parindent and no parskips
\begin{singlespace}
\setlength\parindent{0pt}
\setlength\parskip{0pt}

%
% Now output the title page
%

\pagestyle{empty}
\pagenumbering{roman}

\ifthenelse{\boolean{phdthesis}}
{
\thispagestyle{empty}

TODO: PhD thesis title page
}
% else: Bachelor/Master/Diploma Thesis title page
{
\thispagestyle{empty}

\vspace*{0.8cm}

\begin{center}

{\LARGE \textbf{\thetitle}}\\[2\baselineskip]

{\large
\thethesistype\\[2\baselineskip]

vorgelegt von\\[2\baselineskip]

\foreach \n [count=\ni] in \theauthor {%
    \textbf{\n}%
    \ifnum\ni=\the@nsmauthorcount%
        \ifnum\the@nsmauthorcount=1%
            \\[1\baselineskip]%
            geb. am \thebirthday\\
            in \thebirthplace\\[2\baselineskip]%
        \else%
            \\[2\baselineskip]%
        \fi%
    \else%
        \\%
    \fi%
}%

angefertigt an der\\[2\baselineskip]

\textbf{%
Technischen Universität Dresden\\[0.2\baselineskip]
Fakultät Informatik\\[0.2\baselineskip]
Networked Systems Modeling\\[0.2\baselineskip]
}
}~\\[1\baselineskip]

\begin{tabular}{>{\raggedleft}p{5cm}p{6cm}}
\ifdef\theadvisors{
\ifthenelse{\equal{\theadvisors}{\thereferees}}{%
}{%
Betreuer:    & %
    \foreach \n [count=\ni] in \theadvisors {%
        \ifnum\ni=1%
        \else%
            \newline
        \fi%
        \textbf{\n}%
    }%
\\
}%
}{}
Gutachter:    & %
    \foreach \n [count=\ni] in \thereferees {%
        \ifnum\ni=1%
        \else%
            \newline
        \fi%
        \textbf{\n}%
    }%
\\
~ & ~\\
Abgabe der Arbeit: & \textbf{\germandateformat\today}\\
\end{tabular}

\end{center}

\clearpage
}
\end{singlespace}

%
% The delaration comes here
%

\ifthenelse{\boolean{phdthesis}}{}
{
\thispagestyle{empty}

\begin{otherlanguage*}{ngerman}
{\Large\noindent%
Erklärung \newline}

\noindent%
Ich versichere, dass ich die Arbeit ohne fremde Hilfe und ohne Benutzung anderer als der angegebenen Quellen angefertigt habe und dass die Arbeit in gleicher oder ähnlicher Form noch keiner anderen Prüfungsbehörde vorgelegen hat und von dieser als Teil einer Prüfungsleistung angenommen wurde.\\
Alle Ausführungen, die wörtlich oder sinngemäß übernommen wurden, sind als solche gekennzeichnet.
\end{otherlanguage*}


\vspace{2cm}


\begin{otherlanguage*}{american}
{\Large\noindent%
Declaration \newline}

\noindent%
I declare that the work is entirely my own and was produced with no assistance from third parties.\\
I certify that the work has not been submitted in the same or any similar form for assessment to any other examining body and all references, direct and indirect, are indicated as such and have been cited accordingly.
\end{otherlanguage*}


\vspace{2cm}

\foreach \n [count=\ni] in \theauthor {%
    \noindent%
    \vspace{1cm}\\
    (\n)\\
    \ifnum\ni=\the@nsmauthorcount%
        Dresden, \americandateformat\today
    \fi
}%



\cleardoublepage
}

\pagestyle{fancy}

}
% -----------------------------------------------------------------------------

