with builtins;

let 
  pkgs = import <nixpkgs> {};

  stdin = readFile ./example.c;

  stdinChars = pkgs.lib.strings.stringToCharacters stdin;

  tokenTypes = {
    eof       = 0;
    id        = 1;
    assig     = 2;
    plus      = 3;
    minus     = 4;
    mult      = 5;
    semi      = 6;
    lparen    = 7;
    rparen    = 8;
    lbrace    = 9;
    rbrace    = 10;
    int       = 11;
    float     = 12;
    bool      = 13;
    char      = 14;
    void      = 15;
    sizet     = 16;
    double    = 17;
    struct    = 18;
    break     = 19;
    _else     = 20;
    switch    = 21;
    long      = 22;
    case      = 23;
    register  = 24;
    typedef   = 25;
    extern    = 26;
    return    = 27;
    union     = 28;
    unsigned  = 29;
    short     = 30;
    continue  = 31;
    for       = 32;
    signed    = 33;
    default   = 34;
    sizeof    = 35;
    volatile  = 36;
    _if       = 37;
    do        = 38;
    static    = 39;
    while     = 40;
    include   = 41;
  };

  makeToken = id: type: [{ id=id; type=type; }];

  keywords = [
    { id = "int";       type = tokenTypes.int;       }
    { id = "float";     type = tokenTypes.float;     }
    { id = "bool";      type = tokenTypes.bool;      }
    { id = "char";      type = tokenTypes.char;      }
    { id = "void";      type = tokenTypes.void;      }
    { id = "size_t";    type = tokenTypes.sizet;     }
    { id = "double";    type = tokenTypes.double;    }
    { id = "struct";    type = tokenTypes.struct;    }
    { id = "break";     type = tokenTypes.break;     }
    { id = "else";      type = tokenTypes._else;     }
    { id = "switch";    type = tokenTypes.switch;    }
    { id = "long";      type = tokenTypes.long;      }
    { id = "case";      type = tokenTypes.case;      }
    { id = "register";  type = tokenTypes.register;  }
    { id = "typedef";   type = tokenTypes.typedef;   }
    { id = "extern";    type = tokenTypes.extern;    }
    { id = "return";    type = tokenTypes.return;    }
    { id = "union";     type = tokenTypes.union;     }
    { id = "unsigned";  type = tokenTypes.unsigned;  }
    { id = "short";     type = tokenTypes.short;     }
    { id = "continue";  type = tokenTypes.continue;  }
    { id = "for";       type = tokenTypes.for;       }
    { id = "signed";    type = tokenTypes.signed;    }
    { id = "default";   type = tokenTypes.default;   }
    { id = "sizeof";    type = tokenTypes.sizeof;    }
    { id = "volatile";  type = tokenTypes.volatile;  }
    { id = "if";        type = tokenTypes._if;       }
    { id = "do";        type = tokenTypes.do;        }
    { id = "static";    type = tokenTypes.static;    }
    { id = "while";     type = tokenTypes.while;     }
    { id = "#include";  type = tokenTypes.include;  }
  ];

  lexSubValue = index:
    if index < (stringLength stdin) then
      let
        char = elemAt stdinChars index;
      in 
        if (match "[) (=;+-]" (toString(char)) != null) then
          ""
        else 
          char + lexSubValue (index + 1) else "";
    
  lexKeyWord = id: index: 
      let 
        key = elemAt keywords index;
      in 
        if      index == (length keywords)  then tokenTypes.id
        else if id == key.id                then key.type
        else    lexKeyWord id (index + 1);
        
  lex' = index: 
    let
      char = elemAt stdinChars index;
    in 
      if index >= (stringLength stdin) then  makeToken "EOF" tokenTypes.eof
      else if (match "[a-zA-Z0-9]" (toString(char)) != null) then
        let 
          id = lexSubValue index;
        in   
          makeToken id (lexKeyWord id 0) ++ (lex' (index + stringLength id))
      else if char == "=" then
        makeToken char tokenTypes.assig ++ (lex' (index + 1))
      else if char == "+" then
        makeToken char tokenTypes.plus ++ (lex' (index + 1))
      else if  char == "-" then
        makeToken char tokenTypes.minus ++ (lex' (index + 1))
      else if  char == "*" then
        makeToken char tokenTypes.mult ++ (lex' (index + 1))
      else if  char == ";" then
        makeToken char tokenTypes.semi ++ (lex' (index + 1))
      else if char == "(" then
        makeToken char tokenTypes.lparen ++ (lex' (index + 1))
      else if char == ")" then
        makeToken char tokenTypes.rparen ++ (lex' (index + 1))
      else if char == "[" then
        makeToken char tokenTypes.lbrace ++ (lex' (index + 1))
      else if char == "]" then
        makeToken char tokenTypes.rbrace ++ (lex' (index + 1))
      else  
        lex' (index + 1);

  lex = lex' 0;
in 
  lex
