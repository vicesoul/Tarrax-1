# coding: utf-8
#
# Copyright (C) 2011 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

def connecting_lead_question_data
  {
    "assessment_question_id" => 4,
    "correct_comments"       => "",
    "id"                     => 1,
    "incorrect_comments"     => "",
    "name"                   => "Question",
    "neutral_comments"       => "",
    "points_possible"        => 50.0,
    "question_name"          => "Question",
    "question_type"          => "connecting_lead_question",
    "connecting_lead_linesNum" => '3',

    "matches" => {
      'left' => [
          {"match_id" => 6061, "text" => "1"},
          {"match_id" => 3855, "text" => "2"},
          {"match_id" => 1397, "text" => "1"},
          {"match_id" => 2369, "text" => "3"},
          {"match_id" => 6065, "text" => "4"},
          {"match_id" => 5779, "text" => "5"}],
      'right' => [
          {"match_id" => 3562, "text" => "6"},
          {"match_id" => 1500, "text" => "7"},
          {"match_id" => 8513, "text" => "8"},
          {"match_id" => 6067, "text" => "a2"},
          {"match_id" => 6068, "text" => "a3"},
          {"match_id" => 6069, "text" => "a4"}]
    },

    "answers"                => [

      {"center"=>"a"  , "comments"=>"" , "text"=>"a"  , "id"=>7396 , "match_left_id"=>6061 , "left"=>"1"   , "match_right_id" => '3562' , "right" => '6'} ,
      {"center"=>"b"  , "comments"=>"" , "text"=>"b"  , "id"=>6081 , "match_left_id"=>3855 , "left" => '2' , 'match_right_id' =>'1500'  , "right"=>"7"}   ,
      {"center"=>"ca" , "comments"=>"" , "text"=>"ca" , "id"=>4224 , "match_left_id"=>1397 , "left" => '1' , 'match_right_id' =>'8513'  , "right"=>"8"}   ,
      {"center"=>"a2" , "comments"=>"" , "text"=>"a" , "id"=>7397 , "match_left_id"=>2369 , "left" => '3' , 'match_right_id' =>'6067'  , "right"=>"a2"}  ,
      {"center"=>"a3" , "comments"=>"" , "text"=>"a"  , "id"=>7398 , "match_left_id"=>6065 , "left" => '4' , 'match_right_id' =>'6068'  , "right"=>"a3"}  ,
      {"center"=>"a4" , "comments"=>"" , "text"=>"a"  , "id"=>7399 , "match_left_id"=>5779 , "left" => '5' , 'match_right_id' =>'6069'  , "right"=>"a4"}  ,

    ], "question_text"=>"<p>Test Question</p>"
  }.with_indifferent_access
end

def connecting_on_pic_question_data
  {
    "assessment_question_id" => 4,
    "correct_comments"       => "",
    "id"                     => 1,
    "incorrect_comments"     => "",
    "name"                   => "Question",
    "neutral_comments"       => "",
    "points_possible"        => 50.0,
    "question_name"          => "Question",
    "question_type"          => "connecting_on_pic_question",
    "answers"                => [

      {"left"=>"ball-1" , "comments"=>"" , "text"=>"a"  , "id"=>1111 , "right"=>"ball-2"}               ,
      {"left"=>"ball-2" , "comments"=>"" , "text"=>"b"  , "id"=>2222 , "right"=>"ball-3ball-4"}         ,
      {"left"=>"ball-5" , "comments"=>"" , "text"=>"ca" , "id"=>5555 , "right"=>"ball-6ball-7"}         ,
      {"left"=>"ball-8" , "comments"=>"" , "text"=>"a"  , "id"=>8888 , "right"=>"ball-9ball-10ball-11"} ,

    ], "question_text"=>"<p>Test Question</p>"
  }.with_indifferent_access
end
