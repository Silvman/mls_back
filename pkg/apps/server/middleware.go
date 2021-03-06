package server

import (
	"context"
	"mls_back/session"
	"net/http"

	"github.com/google/uuid"
)

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			// w.Header().Set("Access-Control-Allow-Origin", config.AllowedIP)
			// w.Header().Set("Access-Control-Allow-Methods", config.AllowedMethods)
			// w.Header().Set("Access-Control-Allow-Credentials", "true")
			// w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

			if r.Method == http.MethodOptions {
				w.WriteHeader(http.StatusOK)
				return
			}
			next.ServeHTTP(w, r)
		})
}

func (srv *Server) authMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			var isAuth bool
			var sess *session.Session
			var id uuid.UUID
			ctx := r.Context()
			s, err := r.Cookie("session-id")
			if err == http.ErrNoCookie {
				isAuth = false
			} else {
				id, err = uuid.Parse(s.Value)
				if err != nil {
					srv.log.Warnln("can't parse ")
					ctx = context.WithValue(ctx, "isAuth", false)
					next.ServeHTTP(w, r.WithContext(ctx))
				}
				isAuth, sess = srv.sm.Check(&session.SessionID{
					ID: id,
				})
				if isAuth {
					ctx = context.WithValue(ctx, "userID", sess.ID)
				}
			}
			ctx = context.WithValue(ctx, "sessionID", id)
			ctx = context.WithValue(ctx, "isAuth", isAuth)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
}

func (srv *Server) logginigMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			srv.log.Infoln(r.Method, r.URL.Path)
			next.ServeHTTP(w, r)
		})
}

func (srv *Server) authRequierMiddleware(next http.Handler) http.Handler {
	srv.log.Println("auth requier miiddleware")
	return http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			if !getIsAuth(r) {
				w.WriteHeader(http.StatusUnauthorized)
				return
			}
			next.ServeHTTP(w, r)
		})
}

func getIsAuth(r *http.Request) bool {
	return r.Context().Value("isAuth").(bool)
}

func getUserID(r *http.Request) int {
	return r.Context().Value("userID").(int)
}

func getSessionID(r *http.Request) uuid.UUID {
	return r.Context().Value("sessionID").(uuid.UUID)
}
