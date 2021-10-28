#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <omp.h>
#include <mpi.h>
#include <string.h>

#define MASTER 0
#define LINE_LENGTH 100
#define NUM_LINES 1 //10000

void initialise(int* nprocs, int* rank, int* size, double* tic);
void finalise(double* tic, int* rank);
void process(int* rank, int* size);

int main(int argc, char* argv[])
{
  int    nprocs, rank;
  char   *buf;
  int    counter = 0;
  int    size;
  double tic;
  MPI_Status status;

  initialise(&nprocs, &rank, &size, &tic);

  process(&rank, &size);

  finalise(&tic, &rank);

  return EXIT_SUCCESS;
}

void process(int* rank, int* size)
{
  FILE* fp;
  char str[20];
  char file[] = ".txt";
  char line[LINE_LENGTH+1];
  line[LINE_LENGTH] = '\0';

  sprintf(str, "%d", *rank);
  fp = fopen(strcat(str,file),"r");

  # pragma omp parallel for
  for (int i = 0; i < *size; i++) {
    fgets(line, LINE_LENGTH, fp);
    system(line);
    // deal with out file
  }
}


void initialise(int* nprocs, int* rank, int *size, double* tic)
{
  MPI_Init(NULL, NULL);
  MPI_Comm_size(MPI_COMM_WORLD, nprocs);
  MPI_Comm_rank(MPI_COMM_WORLD, rank);

  struct timeval timstr;
  int final_line_count;
  int line_per_rank;

  // add calculate NUM_LINES?

  if (*rank == MASTER)
  {
    gettimeofday(&timstr, NULL);
    *tic = timstr.tv_sec + (timstr.tv_usec / 1000000.0);

    int rem = NUM_LINES % *nprocs;

    if (rem != 0)
    {
      line_per_rank = NUM_LINES / *nprocs + 1;
      final_line_count = NUM_LINES - line_per_rank*(*nprocs-1);
    }
    else
    {
      line_per_rank = final_line_count = NUM_LINES / *nprocs;
    }

    FILE* fid = fopen("t2_stor.txt", "r");
    int line_counter = 0;
    char line[LINE_LENGTH+1];
    line[LINE_LENGTH] = '\0';
    char str[20];

    // array of fps to prevent reopening?
    for (int i = 0; i < NUM_LINES; i++)
    {
      fgets(line, LINE_LENGTH, fid);
      int r = i / line_per_rank;
      sprintf(str, "%d", r);
      FILE* r_file = fopen(strcat(str,".txt"), "a");
      fwrite(line, sizeof(line), 1, r_file);
      fclose(r_file);
    }
    fclose(fid);
  }

  *size = line_per_rank;
  if (rank == nprocs-1) *size = final_line_count;
}

void finalise(double* tic, int* rank)
{
  struct timeval timstr;
  struct rusage ru;
  double toc;
  double usrtim;
  double systim;
  if (*rank == MASTER)
  {

  gettimeofday(&timstr, NULL);
  toc = timstr.tv_sec + (timstr.tv_usec / 1000000.0);
  getrusage(RUSAGE_SELF, &ru);
  timstr = ru.ru_utime;
  usrtim = timstr.tv_sec + (timstr.tv_usec / 1000000.0);
  timstr = ru.ru_stime;
  systim = timstr.tv_sec + (timstr.tv_usec / 1000000.0);


  printf("Elapsed time:\t\t\t%.6lf (s)\n", toc - *tic);
  printf("Elapsed user CPU time:\t\t%.6lf (s)\n", usrtim);
  printf("Elapsed system CPU time:\t%.6lf (s)\n", systim);
  }
  MPI_Finalize();
}














  /*
  int nx = 28; // rows
  int ny = 1; // cols

  MPI_Datatype filetype;
  int global_size[2] = {nx, ny};
  int local_size[2] = {nx/nprocs, ny};
  int starts[2] = {rank*local_size[0], 0};
  int size = (nx/nprocs)*ny+1;
  char line[size];
  MPI_Type_create_subarray(2, global_size, local_size, starts, MPI_ORDER_C, MPI_CHAR, &filetype);
  MPI_Type_commit(&filetype);

  MPI_File file;
  MPI_File_open(MPI_COMM_WORLD, "test1.txt", MPI_MODE_RDONLY, MPI_INFO_NULL, &file);
  MPI_File_set_view(file, 0, MPI_CHAR, filetype, "native", MPI_INFO_NULL);
  MPI_File_read_all(file, line, local_size[0]*local_size[1], MPI_CHAR, MPI_STATUS_IGNORE);

  //line[size-1] = '\0';
  char command[100];
  strcpy(command, "echo ");
  strcat(command, line);
  system(command);

  MPI_File_close(&file);

  // code
  for (int i = 0; i < 20 ; i++)
  {
    int status_sys = system("./hello");
    printf("%d / %d: %d\n", i, rank, status_sys);
  }
  MPI_File fh;
  MPI_File_open(MPI_COMM_WORLD, "test.txt", MPI_MODE_RDONLY, MPI_INFO_NULL, &fh);
  buf = (char *)malloc( nprocs * sizeof(char));
  buf[0] = rank;
  MPI_File_read(fh, buf, 100, MPI_CHAR, &status);
  puts(buf);

  MPI_File_close(&fh);

  */
