---
title: Notifications
description: Notifications for players
sidebar_position: 6
---

# Notifications

Server-side chat notifications.

```js
-- A single player
Mantle.notify(pl, Color(75, 0, 0), 'Title', 'Message text')

-- Every player
Mantle.notify(true, Color(0, 120, 200), 'Server', 'Event started')
```

| Argument      | Type            | Description                                       |
| ------------- | --------------- | ------------------------------------------------- |
| `pl`          | `player / true` | Player. `true` sends the notification to everyone |
| `headerColor` | `color`         | Header color                                      |
| `header`      | `string`        | Message header                                    |
| `text`        | `string`        | Message text                                      |
