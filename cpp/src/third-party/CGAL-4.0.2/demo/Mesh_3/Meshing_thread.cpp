// Copyright (c) 2010 INRIA Sophia-Antipolis (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
// You can redistribute it and/or modify it under the terms of the GNU
// General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Licensees holding a valid commercial license may use this file in
// accordance with the commercial license agreement provided with the software.
//
// This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
// WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// $URL: svn+ssh://scm.gforge.inria.fr/svn/cgal/branches/releases/CGAL-4.0-branch/Mesh_3/demo/Mesh_3/Meshing_thread.cpp $
// $Id: Meshing_thread.cpp 67117 2012-01-13 18:14:48Z lrineau $
//
//
// Author(s)     : Stephane Tayeb
//
//******************************************************************************
// File Description : 
//******************************************************************************


#include <QTime>
#include <QApplication>

#include "Meshing_thread.h"
#include "Scene_c3t3_item.h"


Meshing_thread::
Meshing_thread(Mesh_function_interface* f, Scene_c3t3_item* item)
  : f_(f)
  , item_(item)
  , time_(0)
  , timer_(new QTimer(this))
  , timer_period_(1)
{
  connect(timer_, SIGNAL(timeout()),
          this,   SLOT(emit_status()));
  
  timer_->start(static_cast<int>(timer_period_*1000));  
}


Meshing_thread::
~Meshing_thread()
{
  delete f_;
  delete timer_;
  QApplication::restoreOverrideCursor();
}


void
Meshing_thread::
run()
{
  QTime timer;
  timer.start();
  
  f_->launch();
  time_ = double(timer.elapsed()) / 1000;
  
  emit done(this);
}


void
Meshing_thread::
stop()
{
  f_->stop();
  
  // Block application until thread is deleted
  QApplication::setOverrideCursor(Qt::WaitCursor);
}


void
Meshing_thread::
emit_status()
{
  emit (status_report(f_->status(timer_period_)));
}


#include "Meshing_thread.moc"
