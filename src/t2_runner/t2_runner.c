#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <mpi.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

#define MASTER 0
#define LINE_LENGTH 124 //130 // keep this, make automatic pref
#define NUM_LINES 1450000
#define VEI_START 2 // make these automatic
#define VEI_END 7

void initialise(int* nprocs, int* rank, int* size, double* tic);
void finalise(double* tic, int* rank);
void process(int* rank, int* size);
void checkError(const int err, const char *op, const int rank, const int line);
int lineCounter(char * filename);
void die(const char* message, const int line, const char* file);

int main(int argc, char* argv[])
{
  int    nprocs, rank;
  char   *buf;
  int    counter = 0;
  double tic;
  int    size;
  MPI_Status status;

  char * file = "0.txt";
  printf("lines %d\n", lineCounter(file));
  initialise(&nprocs, &rank, &size, &tic);

  //process(&rank, &size);

  //MPI_Barrier(MPI_COMM_WORLD);
  finalise(&tic, &rank);

  return EXIT_SUCCESS;
}

void process(int* rank, int* size)
{
  FILE* fp;
  char str[20];
  char file[] = ".txt";
  char line[LINE_LENGTH];
  char message[1024];

  printf("Rank: %d, Size: %d\n", *rank, *size);
  sprintf(str, "%d", *rank);
  fp = fopen(strcat(str,file),"r");
  if( fp == NULL ) {
    sprintf(message, "Could not open %s: %s\n", str, strerror(errno));
    die(message, __LINE__, __FILE__);
  }
/*
  for (int j = VEI_START; j < VEI_END+1; j++)
  {
    for (int i = 0; i < *size; i++) {
      fgets(line, LINE_LENGTH+10, fp);
      
      system(line);
      char * stdout_file = strrchr(line, ' ');
      char rem[] = "rm ";
      strcat(rem, stdout_file);
      system(rem);
      
    }
    printf("rank %d: VEI%d complete\n", *rank, j);
  }
*/
}

int lineCounter(char * filename)
{
  int stdout_bk;
  int pipefd[2];
  char buf[101];
  char * token;
  stdout_bk = dup(fileno(stdout));
  pipe2(pipefd, 0);
  dup2(pipefd[1], fileno(stdout));

  char command[50] = "wc -l < ";
  strcat(command, filename);
  system(command);

  fflush(stdout);
  close(pipefd[1]);

  dup2(stdout_bk, fileno(stdout));
  read(pipefd[0], buf, 100);

  token = strtok(buf, " ");
  return atoi(token);
}

typedef struct
{
  int lines;
  int number;
  char * filename;
  FILE * fid;
} vei_file;

void assignLines(int* nprocs, int* rank, int* size, double* tic)
{
  int counts[*nprocs];
  vei_file veis[VEI_END-VEI_START + 1];
  char message[1024];

  char *conf = getenv("CONF");
  if (conf == NULL)
  {
    die("source ./bin/conf.sh to configure environment.", __LINE__, __FILE__);
  }
  char t2_file[] = "t2.txt";

  int total_lines = 0;
  int j;
  // array of fps to prevent reopening?
  for (j = VEI_START; j < 3; j++)//VEI_END+1; j++)
  {
    char vei[6];
    snprintf(vei, 7, "/VEI%d/", j);
    char *fullfile = (char*) malloc(strlen(conf) + strlen(vei) + strlen(t2_file) + 1);
    strcpy(fullfile, conf);
    strcat(fullfile, vei);
    strcat(fullfile, t2_file);
    FILE *fid;
    fid = fopen(fullfile, "r");
    if( fid == NULL ) {
        sprintf(message, "Could not open %s: %s\n", fullfile, strerror(errno));
        die(message, __LINE__, __FILE__);
    }
    int index = j - VEI_START;
    veis[index].filename = (char*) malloc(strlen(conf) + strlen(vei) + strlen(t2_file) + 1);
    strcpy(veis[index].filename, fullfile);
    veis[index].fid = fid;
    veis[index].number= j;
    veis[index].lines = lineCounter(veis[index].filename);
    total_lines += veis[index].lines;

    printf("filename: %s\nnumber: %d\nlines: %d\n", veis[index].filename, veis[index].number, veis[index].lines);
    free(fullfile);
  }
  printf("total lines: %d\n", total_lines);



  total_lines=0;
  int num_ps = 56;
  int lines_p_proc[num_ps];
  int lines_vei[6];

  int i;
  for(i = 0; i < 6; i++)
  {
    lines_vei[i] = 1370000;
    total_lines += lines_vei[i];
  }
  printf("total lines: %d\n", total_lines);

  int lower_bound = (total_lines / 10000) / num_ps;
  int upper_bound = lower_bound + 1;

  int upper_count = (total_lines/10000) - (lower_bound * num_ps);
  int lower_count = num_ps - upper_count;

  printf("upper: %d * %d + lower: %d * %d = final: %d\n", upper_count, upper_bound, lower_count, lower_bound, ((upper_count*upper_bound)+(lower_count*lower_bound))*10000);

  for (i = 0; i < num_ps; i++)
  {
    lines_p_proc[i] = (i < lower_count) ? lower_bound : upper_bound;
    lines_p_proc[i] *= 10000;
 //   printf("%d: %d\n", i, lines_p_proc[i]);
  }

  // for vei file
  // i = 0 
  // lnies_p_proc[i] check against, once complete 10000* value, increment i, open 0.txt file based on i
  //

  int k;
  int current_rank = 0;
  int lines_done = 0;
  char line[LINE_LENGTH];
  for (j = VEI_START; j < VEI_END+1; j++)
  {
    if (veis[j-VEI_START].fid == NULL) printf("null fid on line %d\n", __LINE__);
    for (k = 0; k < veis[j-VEI_START].lines; k++)
    {
      fgets(line, LINE_LENGTH+10, veis[j-VEI_START].fid);
      char * cur_str;
      sprintf(cur_str, "%d", current_rank);
      FILE* r_file = fopen(strcat(cur_str, ".txt"), "a");
      if( r_file == NULL ) {
        sprintf(message, "Could not open %s: %s\n", cur_str, strerror(errno));
        die(message, __LINE__, __FILE__);
      }
      fwrite(line, sizeof(line), 1, r_file);
      fclose(r_file);
      lines_done++;
      if (lines_done == lines_p_proc[current_rank]) current_rank++;
      printf("line");
    }
  }




  for (j = VEI_START; j < 3; j++)// VEI_END+1; j++)
  {
    free(veis[j-VEI_START].filename);
  }


}



void initialise(int* nprocs, int* rank, int *size, double* tic)
{
  MPI_Init(NULL, NULL);
  MPI_Comm_size(MPI_COMM_WORLD, nprocs);
  MPI_Comm_rank(MPI_COMM_WORLD, rank);
  printf("Number of processes: %d, rank: %d\n", *nprocs, *rank);
  MPI_Status status;

  assignLines(nprocs, rank, size, tic);
/*
  int err;

  struct timeval timstr;
  int final_line_count;
  int line_per_rank;
  int* bcast_buffer = malloc(sizeof(int));

  if (*rank == MASTER)
  {
    gettimeofday(&timstr, NULL);
    *tic = timstr.tv_sec + (timstr.tv_usec / 1000000.0);

    int rem = NUM_LINES % *nprocs;

    if (rem != 0)
    {
      line_per_rank = NUM_LINES / *nprocs;
      final_line_count = rem + line_per_rank;
    }
    else
    {
      line_per_rank = final_line_count = NUM_LINES / *nprocs; // change to be multiple of 10000? Race condition on output file
    }

    char line[LINE_LENGTH];
    char str[20];

    char *conf = getenv("CONF");
    if (conf == NULL)
    {
      printf("source ./bin/conf.sh to configure environment.\n");
      return;
    }
    char t2_file[] = "t2.txt";

    // array of fps to prevent reopening?
    
    for (int j = VEI_START; j < VEI_END+1; j++)
    {
      char vei[6];
      snprintf(vei, 7, "/VEI%d/", j);
      char *fullfile = (char*) malloc(strlen(conf) + strlen(vei) + strlen(t2_file) + 1);
      strcpy(fullfile, conf);
      strcat(fullfile, vei);
      strcat(fullfile, t2_file);
      FILE *fid;
      fid = fopen(fullfile, "r");
      if( fid == NULL ) {
          fprintf(stderr, "Couldn't open %s: %s\n", fullfile, strerror(errno));
          exit(1);
      }
      for (int i = 0; i < NUM_LINES; i++)
      {
        fgets(line, LINE_LENGTH+10, fid);
        int r = i / line_per_rank;
        if (r > *nprocs-1) r = *nprocs-1;
        sprintf(str, "%d", r);
        FILE *r_file;
        r_file = fopen(strcat(str,".txt"), "a");
        if( r_file == NULL ) {
            fprintf(stderr, "Couldn't open %s: %s\n", str, strerror(errno));
            exit(1);
        }
        fwrite(line, sizeof(line), 1, r_file);
        fclose(r_file);
      }
      fclose(fid);
      free(fullfile);
    }
	

    *bcast_buffer = line_per_rank;
    printf("bcast_buffer per VEI per rank: %d\n", *bcast_buffer);
    err = MPI_Send(&final_line_count, 1, MPI_INT, *nprocs-1, 0, MPI_COMM_WORLD);
    checkError(err, "sending final line count", *rank, __LINE__);
    *size = final_line_count; // in case only 1 rank final if condition not met
  }
  else if (*rank == *nprocs-1) {
    err = MPI_Recv(size, 1, MPI_INT, MASTER, 0, MPI_COMM_WORLD, &status);
    checkError(err, "receiving final line count", *rank, __LINE__);
  }
  err = MPI_Bcast(bcast_buffer, 1, MPI_INT, MASTER, MPI_COMM_WORLD);
  checkError(err, "broadcasting amount of lines", *rank, __LINE__);

  if (*rank != *nprocs-1) *size = *bcast_buffer;
  */
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

void checkError(const int err, const char *op, const int rank, const int line)
{
  if (err != MPI_SUCCESS)
  {
    fprintf(stderr, "MPI error during '%s' for rank %d on line %d: %d\n", op, rank, line, err);
    fflush(stderr);
    exit(EXIT_FAILURE);
  }
}

void die(const char* message, const int line, const char* file)
{
  fprintf(stderr, "Error at line %d of file %s:\n%s\n", line, file, message);
  fflush(stderr);
  exit(EXIT_FAILURE);
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
