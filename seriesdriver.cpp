/*
Author Information
  Author name: Kevin Ochoa
  Author email: ochoakevinm@gmail.com
Project Information
  Project title: Harmonic Series Optimization
  Purpose: The purpose of this assignment is to calculate the harmonic sum using vector processing to achieve the least amount of clock cycles.
  Project files: harmonicseries.asm, seriesdriver.cpp
Module Information
  This module's call name: series.out
  Date last modified: 2015-11-30
  Language: C++
  Purpose: This module serves as the driver for harmonic_series. It creates two double pointers and calls harmonic_series. The driver then prints the harmonic sum value and
           the last term in the series that it receives from the assembly program.
  Filename: harmonicdriver.cpp
Translator Information:
   Gnu compiler: g++ -c -m64 -Wall -l seriesdriver.lis -o seriesdriver.o seriesdriver.cpp
   Gnu linker:   g++ -m64 -o series.out seriesdriver.o harmonicseries.o 
References and Credits:
   Holliday, Floyd. Floating Point Input and Output. N.p., 1 July 2015. Web. 30 Nov 2015
   Holliday, Floyd. Instructions acting on SSE and AVX. N.p., 27 August 2015. Web. 30 Nov. 2015. 
   Holliday, Floyd. trapcomputation.asm. N.p., 15 February 2012, Web. 30 Nov 2015
Format Information
  Page width: 172 columns
  Begin Comments: 61
Permission information: No restrictions on posting this file online.
*/
//====== Beginning of seriesdriver.cpp =========================================================================================================================================
#include <iostream>
#include <iomanip>
using namespace std;

extern "C" void harmonic_series(double *a, double*b);

int main()
{
        double*a  = new(double);
        double*b  = new(double);
	cout << "Welcome to the harmonic series by Kevin Ochoa" << endl;
        cout << endl;
	harmonic_series(a,b);
	cout << setprecision(18) << fixed << showpoint;
	cout << "The driver recieved these two numbers: ";
        cout << *a << " and " << *b << "." << endl;
	cout << "The driver will now return a 0 to the operating system. Bye." << endl;
	return 0;
}
//===== End of seriesdriver.cpp ================================================================================================================================================
