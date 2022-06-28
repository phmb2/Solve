//
//  Constants.swift
//  Solve
//
//  Created by Pedro Barbosa on 06/12/21.
//

import Firebase

let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_BANKS = DB_REF.child("banks")
let REF_COMPLAINTS = DB_REF.child("complaints")
let REF_USER_COMPLAINTS = DB_REF.child("user-complaints")
let REF_USER_FOLLOWING = DB_REF.child("user-following")
let REF_USER_FOLLOWERS = DB_REF.child("user-followers")
let REF_COMPLAINT_REPLIES = DB_REF.child("complaint-replies")
let REF_USER_LIKES = DB_REF.child("user-likes")
let REF_COMPLAINT_LIKES = DB_REF.child("complaint-likes")
let REF_NOTIFICATIONS = DB_REF.child("notifications")
let REF_USER_REPLIES = DB_REF.child("user-replies")
let REF_USER_USERNAMES = DB_REF.child("user-usernames")
