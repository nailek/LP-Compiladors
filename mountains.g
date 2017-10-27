#header
<<
#include <string>
#include <iostream>
using namespace std;

// struct to store information about tokens
typedef struct {
  string kind;
  string text;
} Attrib;

// function to fill token information (predeclaration)
void zzcr_attr(Attrib *attr, int type, char *text);

// fields for AST nodes
#define AST_FIELDS string kind; string text;
#include "ast.h"

// macro to create a new AST node (and function predeclaration)
#define zzcr_ast(as,attr,ttype,textt) as=createASTnode(attr,ttype,textt)
AST* createASTnode(Attrib* attr, int ttype, char *textt);
>>

<<
#include <cstdlib>
#include <cmath>
#include <list>

//global structures
AST *root;

typedef struct {
	int length; 
	string kind;
} slope;

typedef struct {
	string id;
	list<slope> definition;
} mountain;

/*
typedef struct {
	string id;
	int first, mid, last;
} peak_valley; 
*/

void treatMountain(AST*);
bool evaluateAssignationExpression(AST*);
void createMountainRecursive(mountain& mountainX, AST *a);
void printPrettyMountain(mountain mountainX);
int calculateMountainHeight(mountain mountainX);
void printMountainHeight(mountain mountainX);

//FuncionsDebugar
void printASTChilds(AST *a);
void printAST(AST *a, int index);
void printSlope(slope);
void printMountain(mountain);
void printMountainDef(mountain);

//FuncionsAuxiliars
void printEndl();

// function to fill token information
void zzcr_attr(Attrib *attr, int type, char *text) {
	if (type == ID) {
		attr->kind = "id";
		attr->text = text;
	}
	else if (type == NUM) {
		attr->kind ="intconst";
		attr->text = text;
	}
	else {
		attr->kind = text;
		attr->text = "";
   }
}

// function to create a new AST node
AST* createASTnode(Attrib* attr, int type, char* text) {
  AST* as = new AST;
  as->kind = attr->kind; 
  as->text = attr->text;
  as->right = NULL; 
  as->down = NULL;
  return as;
}

/// create a new "list" AST node with one element
AST* createASTlist(AST *child) {
  AST *as = new AST;
  as->kind = "list";
  as->right = NULL;
  as->down = child;
  return as;
}

/// get nth child of a tree. Count starts at 0.
/// if no such child, returns NULL
AST* child(AST *a, int n) {
  AST *c = a->down;
  for (int i=0; c!=NULL && i<n; i++) c = c->right;
  return c;
}


/// print AST, recursively, with indentation
void ASTPrintIndent(AST *a, string s) {
  if (a == NULL) return;

  cout << a->kind;
  if (a->text != "") cout << "(" << a->text << ")";
  cout << endl;

  AST *i = a->down;
  while (i != NULL && i->right != NULL) {
    cout << s+"  \\__";
    ASTPrintIndent(i, s+"  |"+string(i->kind.size()+i->text.size(), ' '));
    i = i->right;
  }
  
  if (i != NULL) {
    cout << s+"  \\__";
    ASTPrintIndent(i, s+"   "+string(i->kind.size()+i->text.size(), ' '));
    i = i->right;
  }
}

/// print AST 
void ASTPrint(AST *a) {
  while (a != NULL) {
    cout << " ";
    ASTPrintIndent(a, "");
    a = a->right;
  }
}


int main() {
  root = NULL;
  ANTLR(mountains(&root), stdin);
  ASTPrint(root);
  treatMountain(root);
}

void treatMountain(AST *a) {
	int inst = 0;
		//cout << "Debug: "  << child(a, inst)->kind << endl;
	while(child(a, inst)) {
		try {
			string childKind = child(a, inst)->kind;
			if (childKind == "is") 
				evaluateAssignationExpression(child(a, inst));
			else if (childKind == "if") ;
			else if (childKind == "wihle") ;
		}
		catch(exception& e) { // Capture all exceptions and prints the error message. Program will keep going after that.
			cout << e.what() << endl;
		}
		inst++;
	}
}

bool evaluateAssignationExpression(AST *a) {
	//Guardar num!!!
		//cout << "Debug: "  << child(a, 0)->kind <<" "<<child(a, 0)->text<< endl;
	AST *id = child(a, 0);
	mountain mountainX;
	createMountainRecursive(mountainX, child(a,1));
	mountainX.id = id->text;

	printMountain(mountainX);
	printPrettyMountain(mountainX);

	printMountainHeight(mountainX);

		//printMountainDef(mountainX);
	
}

void createMountainRecursive(mountain& mountainX, AST *a) {
	slope slopeX;
		cout << "Debug: "  << a->kind << endl;
	if (a->kind == ";") {
		int inst = 0;
		while(child(a, inst)) {
			createMountainRecursive(mountainX, child(a, inst));
			inst++;
		}
	}
	else if (a->kind == "*") {
			//printASTChilds(a);
		slopeX.length = atoi(child(a, 0)->text.c_str());
		slopeX.kind = child(a, 1)->kind;
		mountainX.definition.push_back(slopeX);
			//printMountain(mountainX);
	}
	//Id d'una altre muntanya
	else if (a->kind == "id") {
		

	}
}

int calculateMountainHeight (mountain mountainX) {
	int top = 0, index = 0, bottom = 0; 
	std::list<slope>::iterator it;
	for (it=mountainX.definition.begin(); it != mountainX.definition.end(); ++it) {
		//printSlope(*it);
		int sLength = (*it).length;
		//cout << "Debug: k: " << (*it).kind << " l: " << sLength << " t: " << top << " i: " << index << " b: " << bottom << endl;
		if((*it).kind == "/") {
			index += sLength;
			if(top <= index) {
				top = index;
				//cout << "Debug:  t: " << top << endl;
			}
		}
		else if((*it).kind == "\\") {
			index -= sLength;
			if(bottom >= index) {
				bottom = index;
				//cout << "Debug:            b: "  << bottom << endl;
			}
		}		
		//cout << "Debug:       i: " << index << endl;	
	}
	return top + abs(bottom);
}

//Prints:
void printMountainHeight(mountain mountainX) {
	cout << "l'altitut final de " << mountainX.id << " és: " << calculateMountainHeight(mountainX) << endl;
}

void printPrettyMountain(mountain mountainX) {
	//Matriu chars
}

void printMountain(mountain mountainX) {
  cout << "Mountain: " << mountainX.id << endl;
  std::list<slope>::iterator it;
  for (it=mountainX.definition.begin(); it != mountainX.definition.end(); ++it)
	  for (int i = 0; i < (*it).length; ++i)
	  	cout << (*it).kind;
  printEndl();
}

//Fuincions Debugar
void printMountainDef(mountain mountainX) {
  cout << "MountainDef: " << mountainX.id << endl;
  std::list<slope>::iterator it;
  for (it=mountainX.definition.begin(); it != mountainX.definition.end(); ++it)
  	cout << (*it).length << (*it).kind;
  printEndl();
}

void printASTChilds(AST *a) {
	cout << "Debug: " << endl;
	int i = 0;
	while (child(a, i)) {
		printAST(child(a, i), i);
		++i;
	}
}

void printAST(AST *a, int index) {
	cout << "Debug: " << index << " - k " << a->kind << " ";
	cout << "t " << a->text << endl;
}

void printSlope(slope slopeX) {
	cout << "Debug: " << " - k " << slopeX.kind << " ";
	cout << "t " << slopeX.length << endl;
}

//Funcions Auxiliars
void printEndl() {
	cout << endl;
}

>>


#lexclass START

#token IS "is"
#token IF "if"
#token ENDIF "endif"
#token WHILE "while"
#token ENDWHILE "endwhile"

#token NOT "NOT"
#token AND "AND"
#token OR "OR "

#token COMPARE_SYMBOL "== | < | >"
#token SUM "\+"

#token PEAK "Peak"
#token VALLEY "Valley"
#token MATCH "Match"
#token HEIGHT "Height"
#token DRAW "Draw"
#token WELLFORMED "Wellformed"
#token COMPLETE "Complete"

#token NUM "[0-9]+" //0??
#token STAR "\*"
#token SLOPE "\/ | \- | \\"
#token CONCATE ";"
#token COMA ","
#token LEFTBRAKE "\("
#token RIGHTBRAKE "\)"

#token ID "[A-Za-z][A-Za-z0-9]*" //Preguntar profe

#token SPACE "[\ \t \n]" << zzskip(); >>


mountains: ((assign | condic | draw | iter | complete ) << #0 = createASTlist(_sibling); >>)*;
//mountains: (assign << #0 = createASTlist(_sibling); >>)*;

//LEFTBRAKE! RIGHTBRAKE!
// //
assign:  ID IS^ assign_value;

assign_value: NUM ( | STAR^ SLOPE (CONCATE^ muntanya)*)
 	| (id_muntanyes | peak_valley) (CONCATE^ muntanya)*
 	;

muntanya: desnivell 
	| id_muntanyes
	| peak_valley
	;

muntanyes: muntanya (CONCATE^ muntanya)*;

desnivell: NUM STAR^ SLOPE;

id_muntanyes: "#"! ID;

peak_valley: (PEAK^ | VALLEY^) LEFTBRAKE! id_opcio_suma COMA! id_opcio_suma COMA! id_opcio_suma RIGHTBRAKE!;

id_opcio_suma: (ID | NUM) (SUM^ (ID | NUM))*;

match: MATCH^ LEFTBRAKE! id_muntanyes COMA! id_muntanyes RIGHTBRAKE!;

draw: DRAW^ LEFTBRAKE! muntanyes RIGHTBRAKE!;

height: HEIGHT^ LEFTBRAKE! id_muntanyes RIGHTBRAKE!;

wellformed: WELLFORMED^ LEFTBRAKE! ID RIGHTBRAKE!;

complete: COMPLETE^ LEFTBRAKE! ID RIGHTBRAKE!;

// //
condic: IF^ LEFTBRAKE! bool_or RIGHTBRAKE! mountains ENDIF!;

bool_or: bool_and (OR^ bool_and)*;

bool_and: bool_not (AND^ bool_not)*;

bool_not: (NOT^ | ) bool_expr;

bool_expr: peak_valley
	| match
	| wellformed
	| (NUM | height) COMPARE_SYMBOL^ (NUM | height)
	;

// //
iter: WHILE^ LEFTBRAKE! bool_or RIGHTBRAKE! mountains ENDWHILE!;