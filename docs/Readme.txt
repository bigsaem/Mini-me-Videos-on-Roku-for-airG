Copyright 2016 Roku Corp.  All Rights Reserved.

Simple Style3 example, with Grid, Details and Video playback SDK2.0

1.Description

This is a Style3 simple sample.

This example has several reusable nodes that can be changed according to the requirements.

The channel has nodes that can be used separately, containing.
1) Home screen with grid (RowList)
2) Details panel with playback buttons and hud.
3) Video player is called by pressing a button on details panel

2. Base Hierarchy of files in project
    - Home scene
        - Fading background
        - Grid panel
        - Description
        - Details panel
            - Description
            - Video

3. Sample of usage
 - Content is downloaded in Main.brs;
 - Interaction between panels based on visibility changes;

3.1. Adding Details Panel to Home Scene
 - Append Details panel to HomeScene children list in Xml file

 - Make a field - alias to GridPanel.content and GridPanel.rowItemSelected in HomeScene interfaces:
 <!-- Content for RowList in GridPanel on Home Scene -->
 <field id="gridContent" type="node" alias="GridPanel.content" onChange="OnChangeContent" />

 <!-- Row item selection handler -->
 <field id="rowItemSelected" type="intarray" alwaysNotify="true" alias="GridPanel.rowItemSelected"/>

 In OnChangeContent set focus directly to gridPanel:
    m.gridPanel.setFocus(true)


 - In OnRowItemSelected callback, hide gridPanel and show detailsPanel
    Function OnRowItemSelected()
        ' On select any item on home scene, show Details node and hide Grid
        m.gridPanel.visible = "false"
        m.detailsPanel.content = m.gridPanel.focusedContent
        m.detailsPanel.setFocus(true)
        m.detailsPanel.visible = "true"
    End Function

 - In OnKeyEvent event loop make functionality for Back remote button
    Function OnKeyEvent(key, press) as Boolean
        ? ">>> HomeScene >> OnkeyEvent"
        result = false
        if press then
            if key = "options"
                ' option key handler
            else if key = "back"

                ' if Details opened
                if m.gridPanel.visible = false and m.detailsPanel.videoPlayerVisible = false
                    m.gridPanel.visible = "true"
                    m.detailsPanel.visible = "false"
                    m.gridPanel.setFocus(true)

                ' if video player opened
                else if m.gridPanel.visible = false and m.detailsPanel.videoPlayerVisible = true
                    m.detailsPanel.videoPlayerVisible = false
                
                end if

                result = true
            end if
        end if
        return result
    End Function
