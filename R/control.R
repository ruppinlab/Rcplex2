
check.Rcplex.control <- function(control, isQP)
  {
    ## default control parameters
    con <- list(
                ## CPLEX parameters
                trace             = 1L,  ## Messages to screen switch
                threads           = 0L,  ## Number of threads: default 0L means automatic. ***added by me 2018.10.7
                parallel.mode     = 0L,  ## Parallel Mode: default 0L means automatic. -1 for opportunistic and 1 for deterministic. ***added by me 2019.11.7
                method            = 0L,  ## Algorithm for optimization
                preind            = 1L,  ## Presolve switch
                aggind            = -1L, ## Preprocessing aggregator limit
                                         ## (reduce rows and columns if
                                         ## possible before problem is solved)
                itlim             = 2.1e+9L,## Simplex maximum iterations limit
                                         ## normally the above should be
                                         ## '.Machine$integer.max' but CPLEX
                                         ## doesn't accept this ... 
                qp.opt            = 0L,  ## QP optimality target: default 0L auto (nonconvex will stop); 1 for global optimality to a convex model; 2 for local optimality; 3 for global optimality for nonconvex, and change problem to MIQP if needed. ***added by me 2021.3.3
                epagap            = 1e-6,## Absolute MIP gap tolerance: ***was 0, changed to cplex default by me
                epgap             = 1e-4,## Relative MIP gap tolerance 
                tilim             = 1e74,## Optimizer time limit [sec]
                disjcuts          = 0L,  ## disjunctive cuts switch
                mipemphasis       = 0L,  ## MIP Emphasis switch
                cliques           = 0L,  ## MIP cliques switch
                nodesel           = 1L,  ## MIP node selection strategy
                probe             = 0L,  ## MIP probing level
                varsel            = 0L,  ## MIP variable selection strategy
                flowcovers        = 0L,  ## MIP flow cover cuts switch
                ## now solution pool: this is really strange
                ## solnpoolagap and solnpoolgap are set to 1e+75 by default
                ## CPXMIP_OPTIMAL_POPULATED (129) only if ALL solution have
                ## obeen found REGARDLESS of an optimum.
                ## If we are interested in ALL OPTIMAL solutions we have to
                ## set the gap to 0, which gives a status code of
                ## CPXMIP_OPTIMAL_POPULATED_TOL (130) except that there are
                ## no more feasible solutions. So be careful with
                ## status codes here!
                solnpoolagap      = 0,## Absolute gap for solution pool
                solnpoolgap       = 0,## Relative gap for solution pool
                ## NOTE: to find all solutions in the CPLEX user's manual
                ## it is recommended to set solnpoolintensity to 4L.
                ## But then MIP solutions are considered to have a status
                ## of CPXMIP_OPTIMAL_TOL (102) instead of CPXMIP_OPTIMAL (101).
                solnpoolintensity = 0L,  ## Solution pool intensity
                ## User parameter
                maxcalls          = 500L,## max calls to CPLEX lib before renewing license
                round             = 0L)  ## round integer solutions after
                                         ## optimization 
    
    con[names(control)] <- control

    if (!is.null(con$trace)) {
      con$trace <- as.integer(con$trace)
      if(!con$trace %in% c(0L, 1L)) {
        warning("Improper value for trace parameter. Using default.")
        con$trace <- 1L
      }
    }

    ## threads: ***added by me 2018.10.7
    if (!is.null(con$threads)) {
      con$threads <- as.integer(con$threads)
      if(con$threads < 0L) {
        warning("Improper value for threads parameter. Using default.")
        con$threads <- 0L
      }
    }

    ## parallel.mode: ***added by me 2019.11.7
    if (!is.null(con$parallel.mode)) {
      con$parallel.mode <- as.integer(con$parallel.mode)
      if(!con$parallel.mode %in% c(-1L, 0L, 1L)) {
        warning("Improper value for parallel.mode parameter. Using default.")
        con$parallel.mode <- 0L
      }
    }

    if (!is.null(con$method)) {
      con$method <- as.integer(con$method)
      ## currently only algorithms 0 to 4 available
      ## FIXME: what to do with 5 (sifting), 6 (concurrent execution)
      if(!con$method %in% 0L:4L) {
        warning("Improper value for method parameter. Using default.")
        con$method <- 0L
      }
      ## Algorithm for QP can only be 0L (automatic) or 4L (barrier)
      if(isQP && (!con$method %in% c(0L,4L))) {
        warning("Improper value for method parameter. Using default.")
        con$method <- 0L
      }
    }

    if (!is.null(con$preind)) {
      con$preind <- as.integer(con$preind)
      if(!con$preind %in% c(0L, 1L)) {
        warning("Improper value for preind parameter. Using default.")
        con$preind <- 1L
      }
    }
    
    if (!is.null(con$aggind)) {
      con$aggind <- as.integer(con$aggind)
      if(con$aggind < 0L && con$aggind != -1L) {
        warning("Improper value for aggind parameter. Using default.")
        con$aggind <- -1L
      }
    }

    if (!is.null(con$itlim)) {
      con$itlim <- as.integer(con$itlim)
      if((con$itlim < 0L) ||  (con$itlim > 2.1e+9L)) {
        warning("Improper value for itlim parameter. Using default.")
        con$itlim <- 2.1e+9L 
      }
    }

    ## qp.opt: ***added by me 2021.3.3
    if (!is.null(con$qp.opt)) {
      con$qp.opt <- as.integer(con$qp.opt)
      if(!con$qp.opt %in% c(0L, 1L, 2L, 3L)) {
        warning("Improper value for qp.opt parameter. Using default.")
        con$qp.opt <- 0L
      }
    }

    if (!is.null(con$epagap)) {
      con$epagap <- as.numeric(con$epagap)
      if (con$epagap < 0) {
        warning("Improper value for epagap parameter. Using default.")
        con$epagap <- 1e-6
      }
    }
    
    if (!is.null(con$epgap)) {
      con$epgap <- as.numeric(con$epgap)
      if(con$epgap < 0 || con$epgap > 1) {
        warning("Improper value for epgap parameter. Using default.")
        con$epgap <- 1e-4 # ***was 0, changed to cplex default by me
      }
    }
    
    if (!is.null(con$tilim)) {
      con$tilim <- as.numeric(con$tilim)
      if(con$tilim < 0) {
        warning("Improper value for tilim parameter. Using default")
        con$tilim <- 1e75
      }
    }

    if (!is.null(con$disjcuts)) {
      con$disjcuts <- as.integer(con$disjcuts)
      if(!con$disjcuts %in% -1L:3L) {
        warning("Improper value for disjcuts parameter: Using default.")
        con$disjcuts <- 0L
      }
    }

    if (!is.null(con$mipemphasis)) {
      con$mipemphasis <- as.integer(con$mipemphasis)
      if(!con$mipemphasis %in% 0L:4L) {
        warning("Improper value for mipemphasis parameter: Using default.")
        con$mipemphasis <- 0L
      }
    }

    if (!is.null(con$cliques)) {
      con$cliques <- as.integer(con$cliques)
      if(!con$cliques %in% -1L:2L) {
        warning("Improper value for cliques parameter: Using default.")
        con$cliques <- 0L
      }
    }

    if (!is.null(con$nodesel)) {
      con$nodesel <- as.integer(con$nodesel)
      if(!con$nodesel %in% 0L:3L) {
        warning("Improper value for nodesel parameter: Using default.")
        con$nodesel <- 1L
      }
    }

    if (!is.null(con$probe)) {
      if(!con$probe %in% -1L:3L) {
        warning("Improper value for probe parameter: Using default.")
        con$probe <- 0L
      }
    }

    if (!is.null(con$varsel)) {
      con$varsel <- as.integer(con$varsel)
      if(!con$varsel %in% -1L:4L) {
        warning("Improper value for varsel parameter: Using default.")
        con$varsel <- 0L
      }
    }

    if (!is.null(con$flowcovers)) {
      con$flowcovers <- as.integer(con$flowcovers)
      if(!con$flowcovers %in% -1L:2L) {
        warning("Improper value for flowcovers parameter: Using default")
        con$flowcovers <- 0L
      }
    }

    if (!is.null(con$solnpoolagap)) {
      con$solnpoolagap <- as.numeric(con$solnpoolagap)
      if(!con$solnpoolagap >= 0) {
        warning("Improper value for solnpoolagap parameter: Using default")
        con$solnpoolagap <- 1e75 # ***was 0, changed to cplex default by me
      }
    }

    if (!is.null(con$solnpoolgap)) {
      con$solnpoolgap <- as.numeric(con$solnpoolgap)
      if(!con$solnpoolgap >= 0) {
        warning("Improper value for solnpoolagap parameter: Using default")
        con$solnpoolgap <- 1e75 # ***was 0, changed to cplex default by me
      }
    }

    if (!is.null(con$solnpoolintensity)) {
      con$solnpoolintensity <- as.integer(con$solnpoolintensity)
      if(!con$solnpoolintensity %in% 0L:4L) {
        warning("Improper value for solnpoolintensity parameter: Using default.")
        con$solnpoolagap <- 0L
      }
    }

    if (!is.null(con$maxcalls)) {
      if(con$maxcalls <= 0L) {
        warning("Improper value for maxcalls parameter. Using default.")
        con$maxcalls <- 500L
      }
    }
    
    if (!is.null(con$round)) {
      if (!con$round %in% c(0,1)) {
        warning("Improper value for round option: Using default")
        con$round <- 0
      }
    }
    return(con)
  }

split.control.list <- function(control){
    R.names <- c("round", "maxcalls")
    C.names <- setdiff(names(control), R.names)
    
    R.control <- control[R.names]
    C.control <- control[C.names]

    return(list(R = R.control, C = C.control))
  }
