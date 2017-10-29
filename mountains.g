#header
<<
#include <string>
#include <iostream>
#include <cstdlib>
#include <cmath>
#include <list>
#include <map>
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

//global structures
AST *root;

typedef struct {
	int length; 
	string kind;
} slope;

typedef struct {
	string id;
	list<slope> def;
} mountain;

map<string,mountain> mountainRepository;

map<string,int> variableRepository;

/*
typedef struct {
	string id;
	int first, mid, last;
} peak_valley; 
*/

void treatExpression(AST*);
bool evaluateAssignationExpression(AST*);
bool evaluateIfExpression(AST*);
bool evaluateBoolExpression(AST*);
int evaluateNumberExpression(AST *a);
void evaluateCallExpression(AST *a);

void createMountainRecursive(mountain& mountainX, AST *a);

slope createSlopeUp(int lengthX);
slope createSlopeCim(int lengthX);
slope createSlopeDown(int lengthX);

int calculateMountainHeight(mountain& mountainX);
void printMountainHeight(mountain& mountainX);


//FuncionsDebugar
void printASTTreeDebug(AST *a);
void printASTTreeRecursiveDebug(int level, AST *a, int index);
void printASTDebug(int level, AST *a, int index);
void printSlopeDebug(slope);
void printMountainPretty(mountain& mountainX);
void printMountain(mountain&);
void printMountainDef(list<slope>& mountainDef);

//FuncionsAuxiliars
void printEndl();
bool has_only_digits(string s);
int getVariableValue(string variable);
int intFromString(string value);

void addBackPeak(list<slope>& mountainDef, int lengthUp, int lengthCim, int lengthDown);
void addBackValley(list<slope>& mountainDef, int lengthDown, int lengthCim, int lengthUp);
void addBackSlopeUp(list<slope>& mountainDef, int length);
void addBackSlopeCim(list<slope>& mountainDef, int length);
void addBackSlopeDown(list<slope>& mountainDef, int length);

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

//// Main //// //// //// //// //// //// //// //// //// //// //// ////

int main() {
  root = NULL;
  ANTLR(mountains(&root), stdin);
  ASTPrint(root);
  treatExpression(root);
}

void treatExpression(AST *a) {
	int inst = 0;
		//cout << "Debug: "  << child(a, inst)->kind << endl;
	while(child(a, inst)) {
		try {
			string childKind = child(a, inst)->kind;
			if (childKind == "is") 
				evaluateAssignationExpression(child(a, inst));
			else if (childKind == "if") 
				evaluateIfExpression(child(a, inst));
			else if (childKind == "wihle") ;
			else if (childKind == "Draw")
				evaluateCallExpression(child(a, inst));
		}
		catch(exception& e) { // Capture all exceptions and prints the error message. Program will keep going after that.
			cout << e.what() << endl;
		}
		inst++;
	}
}

////Evaluate Variable Espression //// ///////////////////////////////////

bool evaluateAssignationExpression(AST *a) {
	//Guardar num!!!
		//printASTTreeDebug(a);
	if(child(a, 1)->kind == "intconst") {
		variableRepository[child(a, 0)->text] = intFromString(child(a, 1)->text);
		//cout << "Debug: id: " << child(a, 0)->text << "  value: " << intFromString(child(a, 1)->text) << "  value map: " << variableRepository[child(a, 0)->text] << endl;
	}
	else {
		//Assignation of mountain
		AST *id = child(a, 0);
		mountain mountainX;
		mountainX.id = id->text;
		createMountainRecursive(mountainX, child(a,1));

		mountainRepository[mountainX.id] = mountainX; 

		printMountain(mountainX);
		printMountainPretty(mountainX);

		printMountainHeight(mountainX);

			//printMountainDef(mountainX);
	}
}

void createMountainRecursive(mountain& mountainX, AST *a) {
	slope slopeX;
		//cout << "Debug: "  << a->kind << " " << a->text << endl;
	if (a->kind == ";") {
		int inst = 0;
		while(child(a, inst)) {
			createMountainRecursive(mountainX, child(a, inst));
			inst++;
		}
	}
	else if (a->kind == "*") {
			//printASTTreeDebug(a);
		slopeX.length = intFromString(child(a, 0)->text);
		slopeX.kind = child(a, 1)->kind;
		mountainX.def.push_back(slopeX);
			//printMountain(mountainX);
	}
	//Id d'una altre muntanya
	else if (a->kind == "id") {
		list<slope> copiedDefinition = mountainRepository[a->text].def;
		mountainX.def.insert(mountainX.def.end(), copiedDefinition.begin(), copiedDefinition.end());
	}
	else if (a->kind == "Peak") {
		int child1, child2, child3;
		//printASTTreeDebug(a);

		child1 = evaluateNumberExpression(child(a, 0));
		child2 = evaluateNumberExpression(child(a, 1));
		child3 = evaluateNumberExpression(child(a, 2));

		addBackPeak(mountainX.def, child1, child2, child3);
	}
	else if (a->kind == "Valley") {
		int child1, child2, child3;
		//printASTTreeDebug(a);

		child1 = evaluateNumberExpression(child(a, 0));
		child2 = evaluateNumberExpression(child(a, 1));
		child3 = evaluateNumberExpression(child(a, 2));

		addBackValley(mountainX.def, child1, child2, child3);
	}
}

int calculateMountainHeight (mountain& mountainX) {
	int top = 0, index = 0, bottom = 0; 
	std::list<slope>::iterator it;
	for (it=mountainX.def.begin(); it != mountainX.def.end(); ++it) {
		//printSlopeDebug(*it);
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

//// Evaluate If Espression //// ///////////////////////////////////

bool evaluateIfExpression(AST *a) {
	//printASTTreeDebug(a);
	if(evaluateBoolExpression(child(a, 0))) {
		//cout << "Debug: if: true" << endl;
		treatExpression(child(a, 1));
	}
	else 
		//cout << "Debug: if: false" << endl;
	printEndl();
}

//// Evaluate Bool Espression //// /////////////////////////////////

bool evaluateBoolExpression(AST* a) {
	int child1, child2;
	if (a->kind == "OR")
		return evaluateBoolExpression(child(a, 0)) || evaluateBoolExpression(child(a, 1));
	else if (a->kind == "AND")
		return evaluateBoolExpression(child(a, 0)) && evaluateBoolExpression(child(a, 1));
	else if (a->kind == "==") {
		//printASTTreeDebug(a);
		return (evaluateNumberExpression(child(a, 0)) == evaluateNumberExpression(child(a, 1)));
	}
	else 
		return evaluateNumberExpression(a);
}

//// Evaluate Number Expression //// ///////////////////////////////

int evaluateNumberExpression(AST *a) {
	if(a->kind == "intconst") 
		return intFromString(a->text);
	else if (a->kind == "+") 
		return evaluateNumberExpression(child(a, 0)) + evaluateNumberExpression(child(a, 1));
	else if (a->kind == "Match") {
		int height1, height2;
		height1 = calculateMountainHeight(mountainRepository[child(a, 0)->text]);
		height2 = calculateMountainHeight(mountainRepository[child(a, 1)->text]);
		//cout << "Debug: Match: h1: " << height1 << " h2: " << height2 << endl;
		return height1 == height2;
	}
	else if (a->kind == "Height") {
		//cout << "Debug: Height: n: " << child(a, 0)->text << " h: " << calculateMountainHeight(mountainRepository[child(a, 0)->text]) << endl;
		return calculateMountainHeight(mountainRepository[child(a, 0)->text]);
	}
	else {
		//cout << "Debug: variable name: " << a->text << " value: " << variableRepository[a->text] << endl;
		return variableRepository[a->text];
	}
}

//// Evaluate Call Expression //// ///////////////////////////////

void evaluateCallExpression(AST *a) {
	if(a->kind == "Draw") {
		printMountain(mountainRepository[child(a, 0)->text]);
	}
}

//// Prints //// ////////////////////////////////////////////////
void printMountainHeight(mountain& mountainX) {
	cout << "l'altitut final de " << mountainX.id;
	cout << " és: " << calculateMountainHeight(mountainX) << endl << endl;
}

void printMountainPretty(mountain& mountainX) {
	//Matriu chars
}

void printMountain(mountain& mountainX) {
  cout << "Mountain: " << mountainX.id << endl;
  std::list<slope>::iterator it;
  for (it=mountainX.def.begin(); it != mountainX.def.end(); ++it)
	  for (int i = 0; i < (*it).length; ++i)
	  	cout << (*it).kind;
  printEndl();
}

void printMountainDef(list<slope>& mountainDef) {
  cout << "Mountain: X" << endl;
  std::list<slope>::iterator it;
  for (it=mountainDef.begin(); it != mountainDef.end(); ++it)
	  for (int i = 0; i < (*it).length; ++i)
	  	cout << (*it).kind;
  printEndl();
}

//// Funcions Debugar //// ///////////////////////////////////////
void printASTTreeDebug(AST *a) {
	printASTTreeRecursiveDebug(0, a, -1);
	printEndl();
}

void printASTTreeRecursiveDebug(int level, AST *a, int index) {
	//cout << "Debug: " << endl;
	int i = 0;
	printASTDebug(level, a, index);
	level++;
	while (child(a, i)) {
		printASTTreeRecursiveDebug(level + 1, child(a, i), i);
		++i;
	}
}

void printASTDebug(int level, AST *a, int index) {
	cout << "Debug: ";
	for(int i = 0; i < level; ++i) cout << "  ";
	cout << index << " - k " << a->kind << " ";
	cout << "t " << a->text << endl;
}

void printSlopeDebug(slope slopeX) {
	cout << "Debug: " << " - k " << slopeX.kind << " ";
	cout << "l " << slopeX.length << endl;
}

////Funcions Auxiliars//// //////////////////////////////////////////////
void printEndl() {
	cout << endl;
}

int getVariableValue(string variable) {

}
int intFromString(string value) {
	return atoi(value.c_str());
}

void addBackPeak(list<slope>& mountainDef, int lengthUp, int lengthCim, int lengthDown) {
	//cout << "Debug: Up: " << lengthUp << " Cim: " << lengthCim << " Down: " << lengthDown << endl;
	addBackSlopeUp(mountainDef, lengthUp);
	addBackSlopeCim(mountainDef, lengthCim);
	addBackSlopeDown(mountainDef, lengthDown);
}
void addBackValley(list<slope>& mountainDef, int lengthDown, int lengthCim, int lengthUp) {
	addBackSlopeDown(mountainDef, lengthDown);
	addBackSlopeCim(mountainDef, lengthCim);
	addBackSlopeUp(mountainDef, lengthUp);
}

void addBackSlopeUp(list<slope>& mountainDef, int length) {
 	mountainDef.push_back(createSlopeUp(length));
}
void addBackSlopeCim(list<slope>& mountainDef, int length) {
 	mountainDef.push_back(createSlopeCim(length));
}
void addBackSlopeDown(list<slope>& mountainDef, int length){
 	mountainDef.push_back(createSlopeDown(length));
}

slope createSlopeUp(int lengthX) {
	slope slopeX;
	slopeX.length = lengthX;
	slopeX.kind = "/";
	return slopeX;
}

slope createSlopeCim(int lengthX) {
	slope slopeX;
	slopeX.length = lengthX;
	slopeX.kind = "-";
	return slopeX;
}

slope createSlopeDown(int lengthX) {
	slope slopeX;
	slopeX.length = lengthX;
	slopeX.kind = "\\";
	return slopeX;
}

//// Tokens //// //// //// //// //// //// //// //// //// //// //// ////

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