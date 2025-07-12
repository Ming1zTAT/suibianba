package com.example.yytfsupportsite.yytf.websocket;

import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import jakarta.websocket.*;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint("/chatSocket/{userId}")
public class ChatWebSocket {

    // 存储在线用户的 WebSocket 会话：key=userId
    private static final Map<Integer, Session> userSessions = new ConcurrentHashMap<>();

    // 每个 WebSocket 实例对应的 userId
    private int userId;

    @OnOpen
    public void onOpen(Session session, @PathParam("userId") int userId) {
        this.userId = userId;
        userSessions.put(userId, session);
        System.out.println("✅ 用户 " + userId + " 已连接 WebSocket");
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        // 若需要客户端发消息广播，可以启用此方法
        // broadcast(message);
    }

    @OnClose
    public void onClose(Session session) {
        userSessions.remove(userId);
        System.out.println("❌ 用户 " + userId + " 已断开 WebSocket");
    }

    @OnError
    public void onError(Session session, Throwable error) {
        System.err.println("WebSocket 错误：" + error.getMessage());
        error.printStackTrace();
    }

    /**
     * ✅ 群聊广播给所有用户（适用于 chatWith == -1）
     */
    public static void broadcastToAll(String json) {
        for (Session session : userSessions.values()) {
            try {
                if (session.isOpen()) {
                    session.getBasicRemote().sendText(json);
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * ✅ 私聊：只发给发送方和接收方
     */
    public static void sendPrivateMessage(int senderId, int receiverId, String json) {
        Session s1 = userSessions.get(senderId);
        Session s2 = userSessions.get(receiverId);

        try {
            if (s1 != null && s1.isOpen()) s1.getBasicRemote().sendText(json);
            if (s2 != null && s2.isOpen()) s2.getBasicRemote().sendText(json);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 工具方法：转义 JSON 字符串内容
     */
    public static String escape(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }

    /**
     * ✅ 外部调用接口（Servlet用）：统一调用这个方法推送 JSON 消息
     */
    public static void pushMessage(int senderId, Integer receiverId, String senderName, String avatar, String content, String imageUrl, String time) {
        String json = "{"
                + "\"senderId\":" + senderId + ","
                + "\"chatWith\":" + (receiverId == null ? -1 : receiverId) + ","
                + "\"senderName\":\"" + escape(senderName) + "\","
                + "\"avatar\":\"" + escape(avatar) + "\","
                + "\"content\":\"" + escape(content) + "\","
                + "\"image\":\"" + escape(imageUrl) + "\","
                + "\"time\":\"" + escape(time) + "\""
                + "}";

        if (receiverId == null || receiverId == -1) {
            broadcastToAll(json);
        } else {
            sendPrivateMessage(senderId, receiverId, json);
        }
    }
}
